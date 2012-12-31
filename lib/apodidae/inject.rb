# -*- encoding: utf-8 -*-
# 例) Inject = {:type => (STRING, INT, INT), :barb => :ul_li もしくは「〜から借りてきたもの」, :injects => [(key(nilもあり), Inject)]}

module Apodidae
  class Inject
    attr_reader :barb_or_val, :type, :branch, :injects

    def initialize(type=nil, barb_or_val=nil, branch=nil, injects=[])
      raise ArgumentError unless injects.all?{|k, v| k.kind_of?(Edge) and v.kind_of?(Inject)}

      @barb_or_val = barb_or_val
      @type = type
      @branch = nil
      @injects = injects
    end

    def barb
      @barb_or_val
    end

    def ==(another_inject)
      (self.barb_or_val == another_inject.barb_or_val) and
      (self.type == another_inject.type) and
      (self.branch == another_inject.branch) and
      (self.injects == another_inject.injects)
    end

    def generate(edge, rachis=nil)
      raise ArgumentError, "#{edge.inspect} is not Edge instance" unless edge.kind_of?(Edge)

      if @barb_or_val.kind_of?(Barb)
        generated_inject_pairs = self.injects.map{|key, inject| [key, inject.generate(key, rachis)]}
        self.barb_or_val.evaluate(edge, generated_inject_pairs)
      else
        rachis.find{|k, v| k.label.to_sym == @barb_or_val.to_s.to_sym}.try(:last)
      end
    end
  end
end
