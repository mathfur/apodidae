# -*- encoding: utf-8 -*-

module Apodidae
  class Barb
    attr_reader :name, :contents, :erbed_contents, :left_edges, :right_edges,
      :min_version, :max_version

    @@all_barbs = []

    def initialize(name, contents)
      @name = name.to_s
      @contents = contents
      @left_edges = []
      @right_edges = []
      @erbed_contents, attrs = erbed(contents)
      @min_version = attrs[:min_version]
      @max_version = attrs[:max_version]
      @@all_barbs << self
    end

    def self.clear_all_barbs
      @@all_barbs = []
    end

    def header_end
      /\s*#\s*__HEADER_END__\s*/
    end

    def able_to_use?
      to_i = ->e{ e.split('.').map(&:to_i) }

      (0 >= (to_i[min_version] <=> to_i[Apodidae::VERSION])) and
        (0 >= (to_i[Apodidae::VERSION] <=> to_i[max_version]))
    end

    def evaluate(left_edge, edge_value_pairs)
      raise ArgumentError, "#{left_edge.inspect} is not Edge instance." unless left_edge.kind_of?(Edge)

      raise "left_edge `#{left_edge.inspect}` is not found in `#{@left_edges.inspect}`" unless @left_edges.include?(left_edge)
      sandbox = Sandbox.new(left_edge, edge_value_pairs)
      begin
        ERB.new(@erbed_contents, nil, '-').result(sandbox.get_binding)
      rescue SyntaxError => e
        raise e, "#{e.message}\n\n#translated erb is following.\n------\n#{@erbed_contents}\n------\n"
      end
    end

    def erbed(contents)
      context = Context.new
      result = contents.to_enum(:each_line).map do |line|
        level = context.level
        index_name = context.index_name

        case line
        when /^(?:\s*)#(?:\s*)apodidae_version:\s*(.*)\s*$/
          low, high = $1.split(/\s*<=\s*/)
          context.min_version = low or raise "wrong version is specified. line: #{line.inspect}"
          context.max_version = high || low
          nil
        when /^(\s*)#-->>\s*(output_to\(?\s*(.*)\)?\s*do\s*)$/
          @left_edges << eval($3)
          context.push([])
          "#$1<%- if #{ $3.rstrip } == edge -%>"
        when /^(?<sp>\s*)#-->>\s*(?<statement>gsub_by\(\s*\{?(?<replacement>.*)\}?\s*\)\s*do\s*)$/
          statement = $~[:statement]
          replacement = Replacement.new("{#{$~[:replacement]}}")
          sp = $~[:sp]

          @right_edges += replacement.open_edges(context)
          context.push(replacement.pairs)
          "#{sp}<%- #{ statement.rstrip } -%>"
        when /^(?<sp>\s*)#-->>\s*(?<statement>loop_by\(\s*\{?(?<replacement>.*)\}?\s*\) do\s*)$/
          statement = $~[:statement]
          replacement = Replacement.new("{#{$~[:replacement]}}")
          sp = $~[:sp]

          raise "loop_by having more than 2 edges cannot be understood." if replacement.size > 1
          edge = replacement.edges.first

          @right_edges += replacement.open_edges(context)
          context.push(replacement.key_label_pairs(level))

          arg_items = replacement.arg_items(level)
          target = context.target(edge)
          target = "#{edge.act_to_value}[#{target}]" if edge.act_to_value

          "#{sp}<%- #{target}.each_with_index do |(#{(edge.range? ? arg_items[0..0] : arg_items).join(', ')}), #{index_name}| -%>"
        when /^(\s*)#-->>\s*end\s*$/
          context.pop
          "#$1<%- end -%>"
        when /^(\s*)#--==( *)(.*)$/
          line = "#$1<%=#$2#{ $3.rstrip } %>"
          context.each do |edge, k|
            line = line.gsub(/(?<replace_target>#{k})\{(?<rear>[^\}]*)\}/){ "proc{#{$~[:rear]}}[#{$~[:replace_target]}]" }
            line = line.gsub(/(?<replace_target>#{k})\.\.\.(?<rear>[a-zA-Z0-9_\.]*)/){ "#{$~[:replace_target]}.#{$~[:rear]}" }
            line = line.gsub(k){ edge.label }
          end
          line.rstrip
        when /^(?<sp>\s*)#-->>\s*gsub_by/
          raise ArgumentError, "gsub_by statement #{line.inspect} is wrong."
        when /^(\s*)#-->>/
          raise ArgumentError, "#{line.inspect} is wrong line."
        else
          context.each do |edge, k|
            replaced_str = if edge.kind_of?(Edge)
                             if edge.act_to_value
                               "#{edge.act_to_value}[#{edge.label}]"
                             else
                               edge.label
                             end
                           else
                             edge
                           end
            line = line.gsub(/(?<replace_target>#{k})\.\{(?<rear>[^\}]*)\}/){ "<%= proc{#{$~[:rear]}}[#{replaced_str}] %>" }
            line = line.gsub(/(?<replace_target>#{k})(?<rear>\.\.\.[a-zA-Z0-9_]*)/){ "<%= #{replaced_str}#{$~[:rear].gsub(/\.\.\./, '.')} %>" }
            line = line.gsub(/#{k}(?!\.\{\|\.\.\.)/){ "<%= #{replaced_str} %>#{$1}" }
          end
          line.rstrip
        end
      end.compact.join("\n")

      return_attributes = {}
      %w{min_version max_version}.each do |k, v|
        return_attributes[k.to_sym] = context.send(k)
      end

      [(result.blank? ? '' : (result + "\n")), return_attributes]
    end

    def self.find_by_name(barb_name)
      @@all_barbs.find{|barb| barb.name.to_s == barb_name.to_s}
    end

    class Sandbox
      # edge :: wanted edge
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

      def loop_by(*args, &block)
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
        all_variable_names = @edge_value_pairs.map(&:first).map(&:label)

        edge_and_value = @edge_value_pairs
          .find{|edge, value| edge.label.to_sym == name.to_sym } or raise "variable or method `#{name}` is not found. \nVARIABLES:\n#{all_variable_names.join("\n")}"
        edge_and_value.try(:last)
      end
    end

    class Context
      attr_accessor :min_version, :max_version

      def initialize
        @value = []
        @min_version = nil
        @max_version = nil
      end

      def level
        @value.size
      end

      def index_name
        "i#{level}"
      end

      def push(before_edge_pairs)
        @value << before_edge_pairs
      end

      def pop
        @value.pop
      end

      def find_from_before(edge)
        flat_value.reverse.find{|after, before| before.to_s == edge.label.to_s}.try(:first)
      end

      def each(&block)
        flat_value.each do |edge, k|
          block.call(edge, k)
        end
      end

      def target(edge)
        self.find_from_before(edge) || edge.label.present_or(first_label)
      end

      private
      def first_label
        flat_value.first.first
      end

      def flat_value
        @value.inject([]){|arr, e| arr+e.to_a}
      end
    end

    class Replacement
      attr_reader :pairs

      def initialize(pairs_str)
        pairs = eval(pairs_str)
        raise "pairs `#{pairs.inspect}` is #{pairs.class}, but it must be Hash." unless pairs.kind_of?(Hash)

        @pairs = {}
        pairs.each do |edge, k|
          @pairs[edge] = k
        end
      end

      def size
        @pairs.size
      end

      def edges
        @pairs.keys
      end

      def open_edges(context)
        self.edges.select{|e| e.label}.reject{|e| context.find_from_before(e) }
      end

      def keys
        @pairs.values.flatten
      end

      def key_label_pairs(prefix)
        result = []
        @pairs.each_with_index do |(edge, ks), i|
          result += ks.map.each_with_index{|k, j| ["k#{prefix}_#{i}_#{j}", k] }
        end
        result
      end

      def arg_items(prefix)
        self.key_label_pairs(prefix).map(&:first)
      end
    end
  end
end
