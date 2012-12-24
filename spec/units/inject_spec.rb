# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Inject do
  describe '#initialize' do
    specify do
      Proc.new { Apodidae::Inject.new(:foo) }.should_not raise_error
    end
  end

  describe '#genreate' do
    before do
      @barb = Apodidae::Barb.new('foo', <<-EOS)
      #-->> gsub_by('hello' => Edge.new(:inner)) do
      #-->> output_to Edge.new(:foo) do
        tag :span, 'hello'
      #-->> end
      #-->> end
      EOS

      @inject1 = Apodidae::Inject.new(:string, :inner)
      @inject2 = Apodidae::Inject.new(:html, @barb, nil, [[:inner, @inject1]])
    end

    specify do
      @inject1.generate(:foo, [[:inner, 'abc']]).should == 'abc'
    end

    specify do
      @inject2.generate(:foo, [[:inner, 'abc']]).should == <<-EOS
        tag :span, 'abc'
      EOS
    end
  end
end
