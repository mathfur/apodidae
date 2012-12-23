# -*- encoding: utf-8 -*-

module Apodidae
  class Prehtml
    def initialize(dsl_src)
      @sandbox = Sandbox.new
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

    def initialize
      @value = []
    end

    def tag(name, attrs={}, &block)
      sandbox = Sandbox.new
      if block_given?
        block_return = sandbox.instance_eval(&block)
        block_value = sandbox.value.blank_then? block_return
      else
        block_value = []
      end
      @value = @value + [{:tag => name.to_s, :attrs => attrs, :inner => block_value}]
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
        when s.scan(/(.+?)\+(.+)/)
          return [zen(s[1])].flatten + [zen(s[2])].flatten
        when s.scan(/(.+?)>(.+)/)
          first_tags = zen(s[1])
          raise "tags before > must only one tag" unless first_tags.kind_of?(Array) and first_tags.size == 1
          first_tag = first_tags.first
          return [first_tag.merge(:inner => [zen(s[2])].flatten || [])]
        when s.scan(/
                    ([a-zA-Z0-9]+)
                    (
                      \[
                        [^\]]*
                      \]
                    )?
                    (?:
                      \{
                        ([^\}]*)
                      \}
                    )?/x)
          return [{:tag => s[1], :attrs => parse_brankets(s[2]), :inner => s[3] || []}]
        end
      end
    end

    def self.parse_brankets(attrs)
      attrs.blank? ? {} : attrs.scan(/\[([^\]=]*)=([^\]=]*)\]/).inject({}){|h, (k, v)| h[k.to_sym] = v; h}
    end
  end
end
