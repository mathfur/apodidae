# -*- encoding: utf-8 -*-

module Apodidae
  class Barb
    attr_reader :name, :contents, :erbed_contents, :left_edges, :right_edges

    @@all_barbs = []

    def initialize(name, contents)
      @name = name.to_s
      @contents = contents
      @left_edges = []
      @right_edges = []
      @erbed_contents = erbed(contents)
      @@all_barbs << self
    end

    def header_end
      /\s*#\s*__HEADER_END__\s*/
    end

    def evaluate(left_edge, rachis)
      raise ArgumentError, "#{left_edge.inspect} is not Edge instance." unless left_edge.kind_of?(Edge)

      sandbox = Sandbox.new(left_edge, rachis)
      begin
        ERB.new(@erbed_contents, nil, '-').result(sandbox.get_binding)
      rescue SyntaxError => e
        raise e, "#{e.message}\n\n#translated erb is following.\n------\n#{@erbed_contents}\n------\n"
      end
    end

    def erbed(contents)
      contexts = []
      result = contents.to_enum(:each_line).map do |line|
        case line
        when /^(\s*)#-->>\s*(output_to\(?\s*(.*)\)?\s*do\s*)$/
          @left_edges << eval($3)
          "#$1<%- if #{ $3.rstrip } == edge -%>"
        when /^(\s*)#-->>\s*((?:loop_by|gsub_by)\(\s*\{?(.*)\}?\s*\) do\s*)$/
          arg_hash = eval("{#$3}")
          @right_edges += arg_hash.values
          contexts << arg_hash
          "#$1<%- #{ $2.rstrip } -%>"
        when /^(\s*)#-->>\s*end\s*$/
          contexts.pop
          "#$1<%- end -%>"
        else
          contexts.each do |context|
            context.each do |k, edge|
              line = line.gsub(k){ "<%= #{edge.label} %>" }
            end
          end
          line.rstrip
        end
      end.join("\n")
      (result.blank? ? '' : (result + "\n"))
    end

    def self.find_by_name(barb_name)
      @@all_barbs.find{|barb| barb.name.to_s == barb_name.to_s}
    end

    class Sandbox
      def initialize(edge, edge_value_pairs)
        @edge = edge
        @edge_value_pairs = edge_value_pairs
        @result = {}
      end

      def get_binding
        binding
      end

      def gsub_by(*args, &block)
        sandbox = Sandbox.new(@edge, @edge_value_pairs)
        sandbox.instance_eval(&block)
        sandbox
      end

      def output_to(target, &block)
        @result[target] = block.call
      end

      def edge
        @edge
      end

      def method_missing(name, *args)
        @edge_value_pairs.find{|edge, value| edge.label.to_sym == name.to_sym }.try(:last)
      end
    end
  end
end
