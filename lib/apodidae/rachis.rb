# -*- encoding: utf-8 -*-

module Apodidae
  class Rachis
    attr_reader :barb_name,:elems
    def initialize(arg)
      case arg
      when Hash, Array
        @elems = Hash[*(arg.map{|k, v| [k.to_sym, v]}).flatten]
      when String
        sandbox = Sandbox.new
        sandbox.instance_eval(arg)
        @elems = sandbox.result
      end
    end

    def [](key)
      @elems[key.to_sym]
    end

    class Sandbox
      attr_reader :result

      def initialize
        @result = {}
      end

      def method_missing(name, *args)
        @result[name.to_sym] = args.first
      end
    end
  end
end
