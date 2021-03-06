# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Inject do
  before do
    Apodidae::Inject.clear_cache
  end

  describe 'no statement' do
    specify do
      Proc.new { Apodidae::Inject.new }.should_not raise_error
    end
  end

  describe 'when input blank edge' do
    before do
      @barb = Apodidae::Barb.new('foo', <<-EOS)
      #-->> gsub_by(Edge.new(:inner) => 'hello') do
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

    it "insert TODO to blank point" do
      @inject2.generate(Apodidae::Edge.new(:foo), []).should == <<-EOS
        tag :span, 'TODO'
      EOS
    end
  end

  describe 'simple statement' do
    before do
      @barb = Apodidae::Barb.new('foo', <<-EOS)
      #-->> gsub_by(Edge.new(:inner) => 'hello') do
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
        #-->> gsub_by(Edge.new(:input, :prehtml) => 'Prehtml_src') do
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

  describe 'use barb like rachis' do
    before do
      @barb1 = Apodidae::Barb.new('like_rachis', <<-EOS)
      #-->> output_to Edge.new(:output) do
        <div>abc</div>
      #-->> end
      EOS

      @barb2 = Apodidae::Barb.new('foo', <<-EOS)
      #-->> gsub_by(Edge.new(:inner) => 'STRING') do
      #-->> output_to Edge.new(:output) do
        tag(:body){ 'STRING' }
      #-->> end
      #-->> end
      EOS

      @inject1 = Apodidae::Inject.new(@barb1, nil, [])
      @inject2 = Apodidae::Inject.new(@barb2, nil, [[Apodidae::Edge.new(:inner), Apodidae::Edge.new(:output), @inject1]])
    end

    specify do
      @inject1.generate(Apodidae::Edge.new(:output), [[]]).should be_equal_ignoring_spaces '<div>abc</div>'
    end

    specify do
      @inject2.generate(Apodidae::Edge.new(:output), [[]]).should == <<-EOS
        tag(:body){ '        <div>abc</div>
' }
      EOS
    end
  end
end
