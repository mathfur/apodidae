# -*- encoding: utf-8 -*-

module Apodidae
  class Combine
    attr_reader :combine

    def initialize(barbs, rachis)
      @barbs = barbs
      @rachis = rachis

      @barb = @barbs.find{|b| b.name == @rachis.barb_name}

      raise "The key #{@rachis.barb_name} is not found in #{@barbs.map(&:name).inspect}." unless @barb

      barb_contents = @barb.contents.gsub(/substitute\([^)]*\)\s*\n/m, '')

      @result = @barb.substitute_rules.inject(barb_contents) do |s, (src,dst)|
        s.gsub(/\b#{src}\b/, @rachis[dst])
      end
    end
  end
end
