# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Connection do
  describe '#initialize' do
    before do
      Apodidae::Barb.clear_all_barbs

      @barb = Apodidae::Barb.new('sample_barb', <<-EOS)
        #-->> gsub_by('hello' => Edge.new(:inner)) do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      EOS

      @barb2 = Apodidae::Barb.new('convert_to_html', <<-EOS)
        #-->> gsub_by('Prehtml_src' => Edge.new(:input, :prehtml)) do
        #-->> output_to Edge.new(:baz, :html) do
        #--==   Prehtml.new(Prehtml_src).to_html
        #-->> end
        #-->> end
      EOS
    end

    describe 'simple case' do
      before do
        @connection = Apodidae::Connection.new(<<-EOS)
            bar(:foo,:sample_barb) do
              inner(:str1)
            end
          EOS
        @inject1 = Apodidae::Inject.new(:str1)
        @inject2 = Apodidae::Inject.new(@barb, nil, [[Apodidae::Edge.new(:inner), Apodidae::Edge.new(:str1), @inject1]])
      end

      specify { @connection.injects.should == [[Apodidae::Edge.new(:bar), Apodidae::Edge.new(:foo), @inject2]] }

      specify do
        @connection.generate(Apodidae::Edge.new(:bar), [[Apodidae::Edge.new(:str1), 'abc']]).should == <<-EOS
          tag(:div) { 'abc' }
        EOS
      end

      specify do
        @connection.generate_all([[Apodidae::Edge.new(:str1), 'abc']]).should == [[Apodidae::Edge.new(:bar), <<-EOS]]
          tag(:div) { 'abc' }
        EOS
      end
    end

    describe 'convert to html' do
      before do
        @connection = Apodidae::Connection.new(<<-EOS)
            abc(:baz, :convert_to_html) do
              input(:foo, :sample_barb) do
                inner(:str1)
              end
            end
          EOS
        @inject1 = Apodidae::Inject.new(:str1)
        @inject2 = Apodidae::Inject.new(@barb, nil, [[Apodidae::Edge.new(:inner), Apodidae::Edge.new(:str1), @inject1]])
        @inject3 = Apodidae::Inject.new(@barb2, nil, [[Apodidae::Edge.new(:input), Apodidae::Edge.new(:foo), @inject2]])
      end

      specify do
        @connection.injects.should ==
          [[Apodidae::Edge.new(:abc, :prehtml), Apodidae::Edge.new(:baz, :prehtml), @inject3]]
      end

      specify do
        @connection.generate(Apodidae::Edge.new(:abc, :html), [[Apodidae::Edge.new(:str1, :prehtml), 'abc']]).should == <<-EOS
        <div>abc</div>
        EOS
      end
    end
  end
end
