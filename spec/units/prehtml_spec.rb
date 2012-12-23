# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Sandbox do
  describe '#tag' do
    describe 'when foo' do
      specify do
        Apodidae::Prehtml.new(%Q!tag(:span, :'data-foo' => 123){'baz'}!).value.
          should == {:tag => 'span', :attrs => {:'data-foo' => 123}, :inner => 'baz'}
      end
    end
  end
end

describe Apodidae::Prehtml do
  describe '#zen' do
    specify do
      Apodidae::Prehtml.new(%Q!zen("div")!).value.should ==
        {
          :tag => 'div',
          :attrs => {},
          :inner => ''
        }
    end

    specify do
      Apodidae::Prehtml.new(%Q!zen("div>span")!).value.should ==
        {
          :tag => 'div',
          :attrs => {},
          :inner => {
            :tag => 'span',
            :attrs => {},
            :inner => ''
          }
        }
    end
  end
end

