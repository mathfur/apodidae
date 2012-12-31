# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Barb do
  describe '#initialize' do
    describe 'when normal argument is specified' do
      subject { Apodidae::Barb.new('foo',<<-EOS) }
          #-->> gsub_by('hello' => Edge.new(:inner_div)) do
          #-->> output_to Edge.new(nil) do
            tag(:div) { 'hello' }
          #-->> end
          #-->> end
        EOS

      specify { subject.left_edges.size.should == 1 }
      specify { subject.left_edges.first.label.should == nil }
      specify { subject.left_edges.first.type.should == :html }

      specify { subject.right_edges.size.should == 1 }
      specify { subject.right_edges.first.label.should == :inner_div }
      specify { subject.right_edges.first.type.should == :html }
    end
  end

  describe '.erbed and #evaluate' do
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
      specify { subject.left_edges.first.type.should == :html }
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
      specify { subject.left_edges[0].type.should == :html }
      specify { subject.left_edges[1].label.should == :bar }
      specify { subject.left_edges[1].type.should == :html }
    end

    it "gsub_by({..})の場合のテストも作成する"
    it "等質ではないrachisの場合は?"
    it "内部に<%が含まれている場合はエスケープする"
  end
end
