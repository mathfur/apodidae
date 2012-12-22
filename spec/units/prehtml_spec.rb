# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Sandbox do
  describe '#tag' do
    describe 'when foo' do
      specify do
        Apodidae::Prehtml.new(<<-EOS).value.should ==
          tag(:div, :class => 'foo', :id => 'bar') do
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
          should == {:tag => 'span', :attrs => {:'data-foo' => 123}, :inner => 'baz'}
      end
    end
  end
end



describe Apodidae::Prehtml do
  describe '#to_html' do
    specify do
      prehtml = Apodidae::Prehtml.new('')
      prehtml.should_receive(:value).at_least(1).and_return(:tag => 'span', :attrs => {:class => 'foo2', :id => 'bar2'}, :inner => 'baz')
      prehtml.to_html.should == %Q!<span class="foo2" id="bar2">baz</span>!
    end

    it "class内にクオートが入っている場合"
    it "フラットにしたい場合"
    it "横幅123に押さえたい場合"
    it "innerがnilの場合とそうでない場合"
  end
end
