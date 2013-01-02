# -*- encoding: utf-8 -*-

module Apodidae
  class Rachis
    attr_reader :barb_name,:elems
    def initialize(arg)
      case arg
      when Hash, Array
        @elems = {}
        arg.each do |edge, value|
          key = edge.kind_of?(Edge) ? edge : Edge.new(edge.to_sym)
          @elems[key] = value
        end
      when String
        sandbox = Sandbox.new
        sandbox.instance_eval(arg)
        @elems = sandbox.result
      end
    end

    def [](edge)
      @elems.find{|k, v| k == edge}.try(:last)
    end

    class Sandbox
      attr_reader :result

      def initialize
        @result = {}
      end

      def group(name, opts={}, &block)
        sandbox = ValueSandbox.new(opts)
        sandbox.instance_eval(&block)
        @result[Edge.new(name.to_sym)] = sandbox.result
      end

      def method_missing(name, *args)
        @result[Edge.new(name.to_sym)] = args.first
      end
    end

    class ValueSandbox
      attr_reader :result

      def initialize(opts={})
        @result = []
        @labels = opts[:labels] || []
        @need_name = opts[:need_name]
      end

      def method_missing(name, *args)
        if @labels.blank?
          @result << [name.to_sym] + args
        else
          hash = {}

          if @need_name
            labels_ = [:name] + @labels
            args_ = [name] + args
          else
            labels_ = @labels
            args_ = args
          end

          labels_.each_with_index do |label, i|
            hash[label] = args_[i]
          end
          @result << hash
        end
      end
    end
  end
end
