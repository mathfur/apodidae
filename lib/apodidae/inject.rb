# -*- encoding: utf-8 -*-
module Apodidae
  class Inject
    attr_reader :barb_or_rachis, :branch, :injects

    def initialize(barb_or_rachis=nil, branch=nil, injects=[])
      injects.each do |e1, e2, inject|
        raise "edge_in `#{e1.inspect} must be Edge" unless e1.kind_of?(Edge)
        raise "edge_out `#{e2.inspect} must be Edge" unless e2.kind_of?(Edge)
        raise "inject `#{inject.inspect} must be Edge" unless inject.kind_of?(Inject)
      end

      @barb_or_rachis = barb_or_rachis
      @branch = nil
      @injects = injects
    end

    def barb
      @barb_or_rachis
    end

    def ==(another_inject)
      (self.barb_or_rachis == another_inject.barb_or_rachis) and
      (self.branch == another_inject.branch) and
      (self.injects == another_inject.injects)
    end

    def generate(wanted_edge, rachis_elems=nil)
      raise ArgumentError, "#{wanted_edge.inspect} is not Edge instance" unless wanted_edge.kind_of?(Edge)

      if @barb_or_rachis.kind_of?(Barb)
        generated_inject_pairs = self.injects.map{|e, wanted_edge, inject| [e, inject.generate(wanted_edge, rachis_elems)]}

        # 現在のbarbに入力する
        self.barb.evaluate(wanted_edge, generated_inject_pairs)
      else
        edge_and_value = rachis_elems
          .find{|e, v| e.label.to_sym == @barb_or_rachis.to_s.to_sym} or
            raise "The keys of rachis_elems `#{rachis_elems.inspect}` don't have `#{@barb_or_rachis.to_s}`"
        edge_and_value.try(:last)
      end
    end
  end
end
