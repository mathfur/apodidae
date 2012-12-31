# -*- encoding: utf-8 -*-

module Apodidae
  class Connection
    def initialize(contents)
      @contents = contents
      @sandbox = Sandbox.new
      @sandbox.instance_eval(contents)
    end

    def generate(edge, rachis)
      self.injects.assoc(edge).try(:last).try(:generate, edge, rachis)
    end

    def generate_all(rachis)
      self.injects.map do |edge, inject|
        [edge, inject.try(:generate, edge, rachis)]
      end
    end

    def injects
      @sandbox.injects
    end

    class Sandbox
      attr_reader :value, :injects

      def initialize
        @injects = []
      end

      def method_missing(label, barb_name, &block)
        barb = Barb.find_by_name(barb_name) || label

        sandbox = Sandbox.new
        sandbox.instance_eval(&block) if block_given?
        @injects << [Edge.new(label), Inject.new(:html, barb, nil, sandbox.injects)]
        @injects
      end
    end
  end
end
