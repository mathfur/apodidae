# -*- encoding: utf-8 -*-

module Apodidae
  class Edge
    attr_reader :type, :label, :act_to_value

    def initialize(label, *args)
      raise ArgumentError unless !label or label.kind_of?(String) or label.kind_of?(Symbol)
      @label, @act_to_value = label.to_s.match(/^([^.{]*)([\.\{].*)?$/)[1..2]
      @label = @label.present? ? @label.to_sym : nil
      @act_to_value = case @act_to_value.to_s
                      when /^\{/
                        @act_to_value.sub(/^\{/, 'proc{')
                      when /^\./
                        %Q!proc{|e| e#{@act_to_value} }!
                      else
                        @act_to_value
                      end

      @type = args.flatten.reject{|a| a.kind_of?(Proc) }.present_or [:prehtml]
    end

    def ==(another_edge)
      (self.label.to_sym == another_edge.label.to_sym and self.act_to_value == another_edge.act_to_value) or
      ((!self.label or !another_edge.label) and self.type  == another_edge.type)
    end

    def head_type
      @type.first
    end

    def range?
      self.head_type == :range
    end
  end
end
