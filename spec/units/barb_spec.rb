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
          <%- output_to Edge.new(:foo) do -%>
            tag(:div) { '<%= inner_div %>' }
          <%- end -%>
          <%- end -%>
        OUTPUT
      end

      specify do
        subject.evaluate(Apodidae::Edge.new(:foo), [[:inner_div, 'hello']]).should == <<-OUTPUT
            tag(:div) { 'hello' }
        OUTPUT
      end

      specify { subject.left_edges.size.should == 1 }
      specify { subject.left_edges.first.type.should == :html }
    end

    it "gsub_by({..})の場合のテストも作成する"
    it "等質ではないrachisの場合は?"
    it "内部に<%が含まれている場合はエスケープする"
  end
end
