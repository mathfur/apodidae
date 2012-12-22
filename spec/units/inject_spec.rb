# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Inject do
  describe 'no statement' do
    specify do
      Proc.new { Apodidae::Inject.new }.should_not raise_error
    end
  end

  describe 'simple statement' do
    before do
      @barb = Apodidae::Barb.new('foo', <<-EOS)
      #-->> gsub_by('hello' => Edge.new(:inner)) do
      #-->> output_to Edge.new(:foo) do
        tag :span, 'hello'
      #-->> end
      #-->> end
      EOS

      @inject1 = Apodidae::Inject.new(:str1)
      @inject2 = Apodidae::Inject.new(@barb, nil, [[Apodidae::Edge.new(:inner), Apodidae::Edge.new(:str1), @inject1]])
    end

    specify do
      @inject1.generate(Apodidae::Edge.new(:str1), [[Apodidae::Edge.new(:str1), 'abc']]).should == 'abc'
    end

    specify do
      @inject2.generate(Apodidae::Edge.new(:foo), [[Apodidae::Edge.new(:str1), 'abc']]).should == <<-EOS
        tag :span, 'abc'
      EOS
    end
  end

  describe 'convert to html' do
    before do
      @barb = Apodidae::Barb.new('convert_to_html', <<-EOS)
        #-->> gsub_by('Prehtml_src' => Edge.new(:input, :prehtml)) do
        #-->> output_to Edge.new(:foo, :html) do
        #--==   Prehtml.new(Prehtml_src).to_html
        #-->> end
        #-->> end
      EOS

      @inject1 = Apodidae::Inject.new(:foo)
      @inject2 = Apodidae::Inject.new(@barb, nil,
        [[Apodidae::Edge.new(:input, :prehtml), Apodidae::Edge.new(:foo, :prehtml), @inject1]])
    end

    specify do
      @inject1.generate(Apodidae::Edge.new(:input), [[Apodidae::Edge.new(:foo), 'abc']]).should == 'abc'
    end

    specify do
      @inject2.generate(Apodidae::Edge.new(:foo, :html), [[Apodidae::Edge.new(:foo, :prehtml), "tag(:div){ 'foo' }"]]).should == <<-EOS
        <div>foo</div>
      EOS
    end
  end
end
