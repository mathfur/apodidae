# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Prehtml::Sandbox do
  describe '#tag' do
    describe do
      specify do
        Apodidae::Prehtml.new(<<-EOS).value.should ==
          tag(:div, :class => 'foo', :id => 'bar') do
            tag(:span, :class => "foo2", :id => "bar2") do
              "baz"
            end
          end
        EOS
        [{
          :tag => 'div',
          :attrs => {:class => 'foo', :id => 'bar'},
          :inner => [{
            :tag => 'span',
            :attrs => {:class => 'foo2', :id => 'bar2'},
            :inner => 'baz'
          }]
        }]
      end

      specify do
        Apodidae::Prehtml.new(%Q!tag(:span, :'data-foo' => 123){'baz'}!).value.
          should == [{:tag => 'span', :attrs => {:'data-foo' => 123}, :inner => 'baz'}]
      end

      specify do
        Apodidae::Prehtml.new(%Q!tag(:br)!).value.
        should == [{:tag => 'br', :attrs => {}, :inner => nil}]
      end

      specify do
        Apodidae::Prehtml.new(%Q!rb('user.name')!).value.
        should == [{:tag => 'rb', :attrs => {}, :inner => 'user.name'}]
      end

      specify do
        Apodidae::Prehtml.new(<<-EOS).value.
          rb("@users.each", ["user"]) do
            rb("user.name")
          end
        EOS
        should == [{:tag => 'rb_block', :attrs => {:statement => "@users.each", :args => ['user']}, :inner => [
          {:tag => 'rb', :attrs => {}, :inner => 'user.name'}
        ]}]
      end

      describe "tag name include not alphanum character" do
        it "raise ArgumentError" do
          Proc.new{ Apodidae::Prehtml.new(%Q!tag(:'br"')!) }.should raise_error(ArgumentError)
         end
      end
    end
  end

  describe '#to_html' do
    before do
      @sandbox = Apodidae::Prehtml::Sandbox.new
    end

    specify do
      @sandbox.instance_variable_set(:@value,
        [{:tag => 'span', :attrs => {:class => 'foo2', :id => 'bar2'}, :inner => 'baz'}])
      @sandbox.to_html.should == %Q!<span class="foo2" id="bar2">baz</span>!
    end

    specify do
      @sandbox.instance_variable_set(:@value,
        [{:tag => 'span', :attrs => {:class => 'foo"'}}])
      @sandbox.to_html.should == %Q!<span class="foo\\""></span>!
    end

    specify do
      @sandbox.instance_variable_set(:@value,
        [{:tag => 'rb', :attrs => {}, :inner => 'user.name'}])
      @sandbox.to_html.should == %Q!<%= user.name %>!
    end

    specify do
      @sandbox.instance_variable_set(:@value,
        [{:tag => 'rb_block', :attrs => {:statement => "@users.each", :args => ['user']}, :inner => [
          {:tag => 'rb', :attrs => {}, :inner => 'user.name'}]}])
      @sandbox.to_html(:multiline => true).should be_equal_ignoring_spaces(<<-EOS)
        <% @users.each do |user| %>
          <%= user.name %>
        <% end %>
      EOS
    end

    describe 'flat option is on' do
      it "return 1 line string" do
        @sandbox.instance_variable_set(:@value,
           [{:tag => 'span', :attrs => {:class => 'foo"'}}])
        @sandbox.to_html.should == %Q!<span class="foo\\""></span>!
      end
    end

    describe 'flat option is off' do
      it "return multiple line string" do
        @sandbox.instance_variable_set(:@value,
          [{:tag => 'span', :attrs => {:class => 'foo"'}, :inner => 'baz'}])
        @sandbox.to_html(:multiline => true).should be_equal_ignoring_spaces %Q!<span class="foo\\"">baz</span>!
      end

      it "return multiple line string with layered tag" do
        @sandbox.instance_variable_set(:@value, [{
          :tag => 'span',
          :attrs => {:class => 'foo"'},
          :inner => [{
            :tag => 'div',
            :attrs => {},
            :inner => 'baz'
          }]
        }])
        @sandbox.to_html(:multiline => true).should be_equal_ignoring_spaces <<-EOS
        <span class="foo\\"">
          <div>baz</div>
        </span>
        EOS
      end
    end
  end
end

describe Apodidae::Prehtml do
  describe '#to_html' do
    before do
      @prehtml = Apodidae::Prehtml.new('')
    end

    describe "width option is 123" do
      it "return lines, and the each line do not have more than 123 length" do
        pending
      end
    end

    it "innerがnilの場合とそうでない場合"
  end
end

describe 'prehtml to html' do
  describe do
    subject do
      Apodidae::Prehtml.new(<<-EOS)
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
      EOS
    end

    specify do
      subject.to_html(multiline: true).should be_equal_ignoring_spaces(<<-EOS)
        <table>
          <tr>
            <td>Suzuki</td>
            <td>suzuki@gmail.com</td>
          </tr>
          <tr>
            <td>Sato</td>
            <td>sato@gmail.com</td>
          </tr>
        </table>
      EOS
    end
  end
end
