# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Barb do
  describe do
    subject { Apodidae::Barb.new('foo',<<-EOS) }
        #-->> gsub_by('hello' => Edge.new(:inner_div)) do
        #-->> output_to Edge.new(nil) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      EOS

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == nil }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :inner_div }
    specify { subject.right_edges.first.type.should == [:prehtml] }
  end

  describe 'blank statement' do
    subject do
      Apodidae::Barb.new(:foo, "")
    end

    specify { subject.erbed_contents.should == '' }
    specify { subject.left_edges.should == [] }
    specify { subject.right_edges.should == [] }
  end

  describe 'simple statement' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> gsub_by('hello' => Edge.new(:inner_div)) do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by('hello' => Edge.new(:inner_div)) do -%>
        <%- if Edge.new(:foo) == edge -%>
          tag(:div) { '<%= inner_div %>' }
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:foo), [[Apodidae::Edge.new(:inner_div), 'hello']]).should == <<-OUTPUT
          tag(:div) { 'hello' }
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.type.should == [:prehtml] }
  end

  describe '2 output_to' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> gsub_by('hello' => Edge.new(:inner_div)) do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end

        #-->> gsub_by('hello2' => Edge.new(:inner_div2)) do
        #-->> output_to Edge.new(:bar) do
          tag(:span) { 'hello2' }
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by('hello' => Edge.new(:inner_div)) do -%>
        <%- if Edge.new(:foo) == edge -%>
          tag(:div) { '<%= inner_div %>' }
        <%- end -%>
        <%- end -%>

        <%- gsub_by('hello2' => Edge.new(:inner_div2)) do -%>
        <%- if Edge.new(:bar) == edge -%>
          tag(:span) { '<%= inner_div2 %>' }
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:foo), [[Apodidae::Edge.new(:inner_div), 'abc'],[Apodidae::Edge.new(:inner_div), 'def']]).should be_equal_ignoring_spaces <<-OUTPUT
          tag(:div) { 'abc' }
      OUTPUT

      subject.evaluate(Apodidae::Edge.new(:bar), [[Apodidae::Edge.new(:inner_div), 'abc'],[Apodidae::Edge.new(:inner_div2), 'def']]).should be_equal_ignoring_spaces <<-OUTPUT
          tag(:span) { 'def' }
      OUTPUT
    end

    specify { subject.left_edges.size.should == 2 }
    specify { subject.left_edges[0].label.should == :foo }
    specify { subject.left_edges[0].type.should == [:prehtml] }
    specify { subject.left_edges[1].label.should == :bar }
    specify { subject.left_edges[1].type.should == [:prehtml] }
  end

  describe do
    subject { Apodidae::Barb.new('foo',<<-EOS) }
        #-->> gsub_by('x' => Edge.new(:eight, [:integer])) do
        #-->> output_to Edge.new(:nine, [:integer]) do
        #--==   1+x
        #-->> end
        #-->> end
      EOS

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by('x' => Edge.new(:eight, [:integer])) do -%>
        <%- if Edge.new(:nine, [:integer]) == edge -%>
        <%=   1+eight %>
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:nine, [:integer]), [[Apodidae::Edge.new(:eight, [:integer]), 8]]).should == <<-OUTPUT
        9
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :nine }
    specify { subject.left_edges.first.type.should == [:integer] }
  end

  describe 'convert to html' do
    subject do
      Apodidae::Barb.new('convert_to_html', <<-EOS)
        #-->> gsub_by('Prehtml_src' => Edge.new(:input, [:prehtml])) do
        #-->> output_to Edge.new(:foo, :html) do
        #--==   Prehtml.new(Prehtml_src).to_html
        #-->> end
        #-->> end
      EOS
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by('Prehtml_src' => Edge.new(:input, [:prehtml])) do -%>
        <%- if Edge.new(:foo, :html) == edge -%>
        <%=   Prehtml.new(input).to_html %>
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:foo, [:html]), [[Apodidae::Edge.new(:input, [:prehtml]), "tag(:div){ 'abc' }"]]).should == <<-OUTPUT
        <div>abc</div>
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :foo }
    specify { subject.left_edges.first.type.should == [:html] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [:prehtml] }
  end

  describe '1 loop_by' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> output_to Edge.new(:output) do
        #-->> loop_by(['WORD', 'MEANING'] => Edge.new(:input, {:str => :html})) do
        tag(:dl) do
          tag(:dt) { 'WORD' }
          tag(:dd) { 'MEANING' }
        end
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- if Edge.new(:output) == edge -%>
        <%- input.each_with_index do |(k0_0_0, k0_0_1), i0| -%>
        tag(:dl) do
          tag(:dt) { '<%= k0_0_0 %>' }
          tag(:dd) { '<%= k0_0_1 %>' }
        end
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:output),
        [[Apodidae::Edge.new(:input),{'WWW' => 'World Wide Web'}]]
      ).should == <<-OUTPUT
        tag(:dl) do
          tag(:dt) { 'WWW' }
          tag(:dd) { 'World Wide Web' }
        end
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :output }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [{:str => :html}] }
  end

  describe '2 loop_by' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> output_to Edge.new(:output) do
        tag(:table) do
          #-->> loop_by(['row', '__i__'] => Edge.new(:input, [:range, {:html => :html}])) do
          tag(:tr) do
            #-->> loop_by(['name', 'Suzuki'] => Edge.new(:row)) do
            tag(:td) { 'Suzuki' }
            #-->> end
          end
          #-->> end
        end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- if Edge.new(:output) == edge -%>
        tag(:table) do
          <%- input.each_with_index do |(k0_0_0), i0| -%>
          tag(:tr) do
            <%- k0_0_0.each_with_index do |(k1_0_0, k1_0_1), i1| -%>
            tag(:td) { '<%= k1_0_1 %>' }
            <%- end -%>
          end
          <%- end -%>
        end
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:output), [[Apodidae::Edge.new(:input),eval(<<-INPUT)]]).should == <<-OUTPUT
        [
          {:name => 'Suzuki', :mail => 'suzuki@gmail.com'},
          {:name => 'Sato', :mail => 'sato@gmail.com'}
        ]
      INPUT
        tag(:table) do
          tag(:tr) do
            tag(:td) { 'Suzuki' }
            tag(:td) { 'suzuki@gmail.com' }
          end
          tag(:tr) do
            tag(:td) { 'Sato' }
            tag(:td) { 'sato@gmail.com' }
          end
        end
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :output }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [:range, {:html => :html}] }
  end

  describe 'insert procedure inside loop_by' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> output_to Edge.new(:output) do
        #-->> loop_by(['WORD', 'MEANING'] => Edge.new("input{|e| e.merge('abc'=>'def') }", {:str => :html})) do
        tag(:dl) do
          tag(:dt) { 'WORD.{|e| e.upcase }' }
          tag(:dd) { 'MEANING' }
        end
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- if Edge.new(:output) == edge -%>
        <%- proc{|e| e.merge('abc'=>'def') }[input].each_with_index do |(k0_0_0, k0_0_1), i0| -%>
        tag(:dl) do
          tag(:dt) { '<%= proc{|e| e.upcase }[k0_0_0] %>' }
          tag(:dd) { '<%= k0_0_1 %>' }
        end
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:output),
        [[Apodidae::Edge.new(:input),{'WWW' => 'World Wide Web'}]]
      ).should == <<-OUTPUT
        tag(:dl) do
          tag(:dt) { 'WWW' }
          tag(:dd) { 'World Wide Web' }
        end
        tag(:dl) do
          tag(:dt) { 'ABC' }
          tag(:dd) { 'def' }
        end
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :output }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [{:str => :html}] }
  end
end
