# -*- encoding: utf-8 -*-

module Apodidae
  class Connection
    def initialize(contents)
      @contents = contents
      @sandbox = Sandbox.new
      @sandbox.instance_eval(contents)
    end

    def generate(edge_in, rachis)
      rachis = rachis.kind_of?(Rachis) ? rachis.elems : rachis

      (_, edge_out, inject = self.injects.find{|ein, eout, inject| ein == edge_in}) or raise "`#{edge_in.inspect}` is not found in #{self.injects.map(&:first).inspect}"
      inject.try(:generate, edge_out, rachis)
    end

    def generate_all(rachis)
      self.injects.map do |edge_in, edge_out, inject|
        [edge_in, inject.try(:generate, edge_out, rachis)]
      end
    end

    def injects
      @sandbox.injects
    end

    class Sandbox
      attr_reader :injects

      def initialize
        @injects = []
      end

      def method_missing(label_in, label_out=nil, barb_name=nil, opts={}, &block)
        raise "method `#{label_in}` does not exist" unless label_out

        barb = Barb.find_by_name((barb_name || '')[/^[^#]*/])
        STDERR.puts "#{barb_name} is not found in all barbs." unless barb
        barb ||= label_out

        branch = (barb_name =~ /#/) ? barb_name : nil

        if (barb_name || '')[/^([a-zA-Z0-9_]+)__conn(#|$)/]
          sandbox = eval("SandboxFor#{$1.camelize}").new
          sandbox.instance_eval(&block) if block_given?
          inject = sandbox
        else
          sandbox = Sandbox.new
          sandbox.instance_eval(&block) if block_given?
          inject = Inject.new(barb, branch, sandbox.injects)
        end

        @injects << [Edge.new(label_in), Edge.new(label_out), inject]
        @injects
      end
    end

    class SandboxForUlLi
      def initialize(indent=0)
        @indent = ' '*indent
        @ul_attrs = {}
        @li_attrs = [{}]
      end

      def method_missing(name, *args)
        name = name.to_s

        if name =~ /^_{2,}/
          @ul_attrs = @li_attrs.pop
          @li_attrs = [{}]
          return
        end

        if @li_attrs.last.has_key?(name)
          @li_attrs.push({})
        end

        @li_attrs.last[name] = args[0]

        case name
        when 'label', 'link'
          @li_attrs.last.set_only_not_nil("#{name}_class", (args[1] || {})[:class])
        else
        end
      end

      def generate(wanted_edge, *args)
        # @li_attrs like [{'label' => '', 'link' => ''}, {'label' => ..}]

        ul_attr_str = Helper.attr_to_str(@ul_attrs, comma: true)
        html = %Q!tag(:ul#{ul_attr_str}) do\n! + @li_attrs.map{|li_attr|
          attrs = {}
          attrs['class'] = li_attr['class_'] if li_attr['class_']

          inner = ''
          inner += (li_attr['label'] || '')[/^rb\)\s*(.*?)$/, 1] || li_attr['label'] if li_attr['label']
          inner += %Q!tag(:img, :src => '#{li_attr['image']}'){ }! if li_attr['image']

          linked_inner = if li_attr['link']
                           attrs = attrs.merge('href' => "#{li_attr['link']}", 'class' => li_attr['link_attr'])
                           %Q!tag(:a#{Helper.attr_to_str(attrs, :comma => true)}){ "#{inner}" }!
                         else
                           inner
                         end

          <<-EOS
          tag(:li#{Helper.attr_to_str((li_attr['attrs'] || {}).merge('class' => li_attr['label_class']), :comma => true)}) do
            #{linked_inner}
          end
          EOS
        }.join("\n") + "end"

        css = <<-EOS
PARENT_CELECTOR ul li{
  display: block;
  float: left;
}
        EOS

        case wanted_edge
        when Edge.new('html')
          html
        when Edge.new('css')
          css
        else
          raise "wrong wanted_edge: #{wanted_edge.inspect}"
        end
      end
    end

    module Helper
      def attr_to_str(attrs, opts={})
        attrs = attrs.remove_nil
        attr_str = (attrs || []).map{|k, v| %Q!#{esc_q(k)[/^(.*?)_?$/, 1]}: "#{esc_q(v)}"!}.join(', ')
        (attr_str.present? ? "#{opts[:comma] ? ',' : ''} #{attr_str}" : '')
      end
      module_function :attr_to_str

      def esc_q(str)
        str.to_s.gsub('"', '\\"')
      end
      module_function :esc_q
    end
  end
end
