# -*- encoding: utf-8 -*-

module Apodidae
  class Prehtml
    def initialize(dsl_src)
      @sandbox = Sandbox.new
      @sandbox.instance_eval(dsl_src)
    end
    def to_html
      @sandbox.val
    end
    def val
      @sandbox.val
    end
  end

  class Sandbox
    attr_reader :val

    def tag(name, attrs, &block)
      @val = if block_given?
        #{:tag => name, :attrs =>
      else
        HtmlTag.new(name, {}, [])
      end
    end

    def to_html(flat_or_multiline=:multiline)
      raise ArgumentError, "tag's second argument must be :m(ultiline) or :f(lat)"  unless %w{multiline flat m f}.include?(flat_or_multiline.to_s)

      @val = if block_given?
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
end
