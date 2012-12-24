# -*- encoding: utf-8 -*-

module Apodidae
  class Edge
    attr_reader :type, :label

    def initialize(label, type=:html)
      @label = label
      @type = type
    end
  end
end
