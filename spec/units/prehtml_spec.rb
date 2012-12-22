# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Prehtml do
  describe '#tag' do
    describe 'when foo' do
      specify do
        Apodidae::Prehtml.new(<<-EOS).value.should ==
          tag(:div, :class => "foo", :id => "bar") do
            tag(:span, :class => "foo2", :id => "bar2") do
              "baz"
            end
          end
        EOS
        {
          :tag => 'div',
          :attrs => {:class => 'foo', :id => 'bar'},
          :inner => {
            :tag => 'span',
            :attrs => {:class => 'foo2', :id => 'bar2'},
            :inner => 'baz'
          }
        }
      end

      specify do
        Apodidae::Prehtml.new(%Q!tag(:span, :'data-foo' => 123){'baz'}!).value.
          should == {:tag => 'span', :attrs => {:'data-foo' => '123'}, :inner => 'baz'}
      end
    end
  end
end
