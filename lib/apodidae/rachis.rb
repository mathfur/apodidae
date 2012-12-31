# -*- encoding: utf-8 -*-

module Apodidae
  class Rachis
    attr_reader :barb_name,:elems
    def initialize(arg)
      case arg
      when Hash, Array
        @elems = Hash[*(arg.map{|k, v| [Edge.new(k.to_sym), v]}).flatten]
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

      def method_missing(name, *args)
        @result[Edge.new(name.to_sym)] = args.first
      end
    end
  end
end
