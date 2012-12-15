# -*- encoding: utf-8 -*-

module Apodidae
  class Rachis
    attr_reader :barb_name,:elems
    def initialize(barb_name,elems={})
      @barb_name = barb_name.to_s
      @elems = Hash[*(elems.map{|k, v| [k.to_s, v]}).flatten]
    end

    def [](key)
      @elems[key.to_s]
    end
  end
end
