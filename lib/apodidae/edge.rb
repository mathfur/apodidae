# -*- encoding: utf-8 -*-

module Apodidae
  class Edge
    attr_reader :type, :label

    def initialize(label, type=:prehtml)
      @label = label
      @type = type
    end

    def ==(another_edge)
      (self.label.to_sym == another_edge.label.to_sym) or
      ((!self.label or !another_edge.label) and self.type  == another_edge.type)
    end
  end
end
