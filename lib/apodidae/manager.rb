# -*- encoding: utf-8 -*-

module Apodidae
  class Manager
    attr_reader :barbs, :rachises, :connection, :result
    def initialize
      @barbs = {}
      @rachises = {}
      @connection = nil

      @result = []
    end

    def generate
      @result = @connection.generate_all(@rachises.to_a)
      self
    end

    def add_barb_from_string(label, src)
      @barbs[label] = Barb.new(label, src)
    end

    def add_barb_from_file(path)
      Dir["#{path}/**/*.barb"].each do |barb_fname|
        label = File.basename(barb_fname)[/^[^.]*/]
        @barbs[label] = Barb.new(label, File.read(barb_fname))
      end
    end

    def set_connection_from_string(arg)
      @connection = Apodidae::Connection.new(arg)
    end

    def set_connection_from_file(fname)
      @connection = Apodidae::Connection.new(File.read(fname))
    end

    def add_rachis(args)
      @rachises = @rachises.merge(args)
    end

    def add_rachis_from_file(path)
      Dir["#{path}/**/*.rachis"].each do |fname|
        @rachises = @rachises.merge(Apodidae::Rachis.new(File.read(fname)).elems)
      end
    end

    def write_to(edge_target_pairs)
      edge_target_pairs.each do |edge, target|
        edge_and_content = @result.find{|e, content| e == edge}
        raise "The edge `#{edge.inspect}` is not found. @result:#{@result.inspect}, edge:#{edge.inspect}" unless edge_and_content
        content = edge_and_content.last
        raise "The edge `#{edge.inspect}` don't have content. @result:#{@result.inspect}, edge:#{edge.inspect}" unless content
        raise "File #{target} is alreasy exist." if File.exist?(target)

        FileUtils.mkdir_p(File.dirname(target))
        open(target, 'w') do |f|
          f.write content
        end
      end
    end
  end
end
