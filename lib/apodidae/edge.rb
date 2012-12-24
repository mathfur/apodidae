# -*- encoding: utf-8 -*-

module Apodidae
  class Edge
    attr_reader :type

    def initialize(label, type)
      @label = label.to_s
      @type = type
    end
  end
end
