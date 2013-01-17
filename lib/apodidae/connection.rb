# -*- encoding: utf-8 -*-

module Apodidae
  class Connection
    def initialize(contents)
      @contents = contents
      @sandbox = Sandbox.new
      @sandbox.instance_eval(contents)
    end

    def generate(edge_in, rachis)
      rachis = rachis.kind_of?(Rachis) ? rachis.elems : rachis

      (_, edge_out, inject = self.injects.find{|ein, eout, inject| ein == edge_in}) or raise "`#{edge_in.inspect}` is not found in #{self.injects.map(&:first).inspect}"
      inject.try(:generate, edge_out, rachis)
    end

    def generate_all(rachis)
      self.injects.map do |edge_in, edge_out, inject|
        [edge_in, inject.try(:generate, edge_out, rachis)]
      end
    end

    def injects
      @sandbox.injects
    end

    class Sandbox
      attr_reader :injects

      def initialize
        @injects = []
      end

      def method_missing(label_in, label_out=nil, barb_name=nil, &block)
        raise "method `#{label_in}` does not exist" unless label_out

        barb = Barb.find_by_name((barb_name || '')[/^[^#]*/]) || label_out
        branch = (barb_name =~ /#/) ? barb_name : nil

        sandbox = Sandbox.new
        sandbox.instance_eval(&block) if block_given?
        @injects << [Edge.new(label_in), Edge.new(label_out), Inject.new(barb, branch, sandbox.injects)]
        @injects
      end
    end
  end
end
