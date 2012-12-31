# -*- encoding: utf-8 -*-

module Apodidae
  class Edge
    attr_reader :type, :label

    def initialize(label, type=:html)
      @label = label
      @type = type
    end

    def ==(another_edge)
      (self.label == another_edge.label) and
      (self.type  == another_edge.type)
    end
  end
end
