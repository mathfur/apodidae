# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Edge do
  describe '#initialize' do
    specify do
      Proc.new { Apodidae::Edge.new(:foo, 'prehtml') }.should_not raise_error
    end

    describe 'label without proc' do
      subject { Apodidae::Edge.new(:foo, :html) }
      specify { subject.type.should == [:html] }
      specify { subject.label.should == :foo }
      specify { subject.act_to_value.should be_nil }
    end

    describe 'label with proc' do
      subject { Apodidae::Edge.new("foo.bar", {:html => :html}) }
      specify { subject.type.should == [{:html => :html}] }
      specify { subject.label.should == :foo }
      specify { subject.act_to_value.should == "proc{|e| e.bar }" }
    end

    describe 'label with block-like proc' do
      subject { Apodidae::Edge.new("bar{|e| e.upcase}", {:html => :html}) }
      specify { subject.type.should == [{:html => :html}] }
      specify { subject.label.should == :bar }
      specify { subject.act_to_value.should == "proc{|e| e.upcase}" }
    end
  end
end
