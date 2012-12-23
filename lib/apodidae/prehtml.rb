# -*- encoding: utf-8 -*-

module Apodidae
  class Prehtml
    def initialize(dsl_src)
      @sandbox = Sandbox.new(self)
      @value = @sandbox.instance_eval(dsl_src)
    end
    def to_html
      @sandbox.value
    end
    def value
      @sandbox.value
    end
  end

  class Sandbox
    attr_reader :value

    def initialize(parent)
      raise ArgumentError unless parent.kind_of?(Prehtml)
      @parent = parent
    end

    def tag(name, attrs, &block)
      @value = {:tag => name.to_s, :attrs => attrs, :inner => block_given? && block.call}
    end

    def zen(statement)
      @value = Helper.zen(statement)
    end

    def to_html(flat_or_multiline=:multiline)
      raise ArgumentError, "tag's second argument must be :m(ultiline) or :f(lat)"  unless %w{multiline flat m f}.include?(flat_or_multiline.to_s)

      @value = if block_given?
        case flat_or_multiline.to_s[0..0]
        when 'f'
          "<#{name}>#{block.call}</#{name}>"
        else
          "<#{name}>\n  #{block.call}\n</#{name}>\n"
        end
      else
        "<#{name}/>"
      end
    end
  end

  class Helper
    def self.zen(statement)
      s = StringScanner.new(statement)

      result = {}
      current_tags = []

      while !s.eos?
        case
        when s.scan(/(.+?)>(.+)/)
          return zen(s[1]).merge(:inner => zen(s[2]) || [])
        when s.scan(/[a-zA-Z0-9]+/)
          return {:tag => s[0], :attrs => {}, :inner => ''}
        end
      end
    end
  end
end
