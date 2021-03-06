# -*- encoding: utf-8 -*-

module Apodidae
  class Prehtml
    def initialize(dsl_src)
      @sandbox = Sandbox.new
      @sandbox.instance_eval(dsl_src)
    end

    def to_html(opt={})
      @sandbox.to_html(opt)
    end

    def value
      @sandbox.value
    end

    class Sandbox
      attr_reader :value

      def initialize
        @value = []
      end

      def tag(name, attrs={}, &block)
        raise ArgumentError, "tag name #{name.inspect} must consist of alphanum" unless name =~ /^[a-zA-Z0-9]+$/
        if block_given?
          sandbox = Sandbox.new
          eval_return = sandbox.instance_eval(&block)
          inner = sandbox.value.present_or eval_return
        else
          inner = attrs[:inner]
        end
        @value << {:tag => name.to_s, :attrs => attrs, :inner => inner}
      end

      def rb(statement, args=nil, &block)
        raise "If block is not given, then args must not be needed." if args and !block_given?

        if block_given?
          sandbox = Sandbox.new
          eval_return = sandbox.instance_eval(&block)
          inner = sandbox.value.present_or eval_return
        else
          inner = statement
        end

        attrs = block_given? ? {:statement => statement, :args => args} : {}
        tag =   block_given? ? 'rb_block' : 'rb'
        @value << {:tag => tag, :attrs => attrs, :inner => inner}
      end

      def to_html(opt={})
        @value ? Helper.to_html(@value, opt[:multiline] || opt[:m]) : ''
      end

      module Helper
        def escape(v)
          v.gsub('"', '\\"')
        end
        module_function :escape

        def to_html(value, multiline)
          arr = value.map{|hash| tag_hash_to_html(hash, multiline)}
          multiline ? arr.join("\n") : arr.join('')
        end
        module_function :to_html

        def tag_hash_to_html(tag_hash, multiline)
          tag = tag_hash[:tag]
          attrs = tag_hash[:attrs]
          rb_statement = attrs.delete(:statement)
          rb_args = attrs.delete(:args)
          attrs = attrs.map{|k, v| %Q!#{k}="#{Helper.escape(v)}"!}.join(' ')
          inner = tag_hash[:inner]
          htmled_inner = case inner
                         when String
                           multiline = false
                           inner
                         when Array
                           Helper.to_html(inner, multiline)
                         when NilClass, FalseClass
                           nil
                         else
                           raise ArgumentError, "#{inner.inspect} must be String, Array, nil or false."
                         end
          before_join = case tag
                        when 'rb'
                          ["<%= #{inner} %>"]
                        when 'rb_block'
                          [
                            "<% #{rb_statement} do |#{rb_args.join(', ')}| %>",
                            multiline ? indent_each_line(htmled_inner) : htmled_inner,
                            "<% end %>"
                          ].compact
                        else
                          [
                            "<#{tag}#{attrs.blank? ? '' : ' '+attrs}>",
                            multiline ? indent_each_line(htmled_inner) : htmled_inner,
                            "</#{tag}>"
                          ].compact
                        end

          multiline ?  before_join.join("\n") : before_join.join('')
        end
        module_function :tag_hash_to_html

        def indent_each_line(str,opt={})
          indent_size = opt[:indent_size] || 2
          str.split("\n").map{|line| "#{' '*indent_size}#{line}"}.join("\n")
        end
        module_function :indent_each_line
      end
    end
  end
end
