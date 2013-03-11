# -*- encoding: utf-8 -*-

module Apodidae

  # This class manager barbs, rachises and connections about inputing or outputing to files.
  class Manager
    attr_reader :barbs, :rachises, :connection, :result
    attr_accessor :edge_target_pairs, :use_apodidae_yml

    def initialize(opts={})
      @barbs = {}
      @rachises = {}
      @connection = nil
      @edge_target_pairs = {}

      if @use_apodidae_yml && (config_fname = opts[:config_file])
        raise "config file #{config_fname} is not found" unless File.exist?(config_fname)
        load_config(YAML.load_file(config_fname))
      end

      @result = []
    end

    def generate
      @result = @connection.generate_all(@rachises.to_a)
      self
    end

    def load_config(config_value)
      config_value.each do |label, val|
        case label
        when 'barb-dir'
          self.add_barb_from_file(val)
        when 'rachis-dir'
          self.add_rachis_from_file(val)
        when 'connection-file'
          self.set_connection_from_file(val)
        when 'output-file'
          val.each do |dealing_label, output_target|
            @edge_target_pairs[Apodidae::Edge.new(dealing_label)] = output_target
          end
        end
      end
    end

    def add_barb_from_string(label, src)
      @barbs[label] = Barb.new(label, src)
    end

    def add_barb_from_file(path)
      each_file(path, 'barb') do |label, barb_contents|
        @barbs[label] = Barb.new(label, barb_contents)
      end
    end

    def set_connection_from_string(arg)
      @connection = Apodidae::Connection.new(arg)
    end

    def set_connection_from_file(fname)
      @connection = Apodidae::Connection.new(File.read(fname))
    end

    def use_clipboard
      raise "pbcopy and pbpaste command are needed." if `which pbcopy`.blank? or `which pbpaste`.blank?
      input = `pbpaste`
      puts "INPUT FROM CLIPBOARD:"
      puts "----------------"
      puts input
      puts "----------------"
      puts "Are you sure to run the statement? (y/n)"
      puts "(If the statement contain arbitrary ruby statements, the statement will be executed in meaning of ruby.)"
      if Kernel.gets.strip == 'y'
        @connection = Apodidae::Connection.new(input)
        @use_clipboard = true
      else
        puts "Stop."
      end
    end

    def add_rachis(args)
      @rachises = @rachises.merge(args)
    end

    def add_rachis_from_file(path)
      each_file(path, 'rachis') do |_, contents|
        @rachises = @rachises.merge(Apodidae::Rachis.new(contents).elems)
      end
    end

    def write_to(edge_target_pairs)
      edge_target_pairs.each do |edge, target|
        _, target_file, anchor = target.match(/^([^#]*)(#.*)?$/).to_a
        edge_and_content = @result.find{|e, content| e == edge}
        raise "The edge `#{edge.inspect}` is not found. @result:#{@result.inspect}, edge:#{edge.inspect}" unless edge_and_content
        content = edge_and_content.last
        raise "The edge `#{edge.inspect}` don't have content. @result:#{@result.inspect}, edge:#{edge.inspect}" unless content

        FileUtils.mkdir_p(File.dirname(target_file))
        existing_content = anchor && File.read(target_file)
        open(target_file, 'w') do |f|
          inserted_content = anchor ? existing_content.gsub(anchor, content) : content
          f.write inserted_content
        end
      end
    end

    def write
      if @use_clipboard
        self.write_to_clipboard
      else
        self.write_to(@edge_target_pairs)
      end
    end

    def write_to_clipboard
      content = @result.map{|e| e.last}.join("\n")

      IO.popen("pbcopy", 'w') do |io|
        io.write content
        puts "==================="
        puts "WRITE TO CLIPBOARD:"
        puts "---------------"
        puts content
        puts "---------------"
      end
      @output_to_clipboard = nil
    end

    def list_barbs_string(path)
      each_file(path, 'barb').map do |label, barb_contents|
        barb = Barb.new(label, barb_contents)
        (
          [label] +
          (
            barb.right_edges.map(&:to_s) +
            ['->'] +
            barb.left_edges.map(&:to_s)
          ).map{|line| "  #{line}"}
        ).join("\n")
      end.join("\n\n")
    end

    private
    # Example:
    #   each_file('foo/bar', 'txt') do |basename, contents|
    #   end
    def each_file(path, ext, &block)
      result = []
      Dir["#{path}/**/*.#{ext}"].each do |fname|
        label = File.basename(fname)[/^([^.]*)\.#{ext}/, 1]
        args = [label, File.read(fname)]
        if block_given?
          block.call(*args)
        else
          result << args
        end
      end
      result
    end
  end
end
