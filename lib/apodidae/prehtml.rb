# -*- encoding: utf-8 -*-

module Apodidae
  class Prehtml
    def initialize(dsl_src)
      @sandbox = Sandbox.new
      @value = @sandbox.instance_eval(dsl_src)
    end

    def to_html
      "<#{value[:tag]} #{value[:attrs].map{|k, v| %Q!#{k}="#{escape(v)}"!}.join(' ')}>#{value[:inner]}</span>"
    end

    def value
      @sandbox.value
    end

    def escape(v)
      v.gsub('"', '""')
    end
  end

  class Sandbox
    attr_reader :value

    def tag(name, attrs, &block)
      @value = {:tag => name.to_s, :attrs => attrs, :inner => block_given? && block.call}
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
end
