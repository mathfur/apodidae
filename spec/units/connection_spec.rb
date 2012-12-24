# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Connection do
  describe '#initialize' do
    before do
      @barb = Apodidae::Barb.new('sample_barb', <<-EOS)
        #-->> gsub_by('hello' => Edge.new(:inner)) do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      EOS
    end

    describe 'simple case' do
      before do
        @connection = Apodidae::Connection.new(<<-EOS)
            foo(:sample_barb) do
              inner(:str1)
            end
          EOS
        @inject1 = Apodidae::Inject.new(:html, :inner)
        @inject2 = Apodidae::Inject.new(:html, @barb, nil, [[:inner, @inject1]])
      end

      specify { @connection.injects.should == [[:foo, @inject2]] }

      specify do
        @connection.generate(:foo, [[:inner, 'abc']]).should == <<-EOS
          tag(:div) { 'abc' }
        EOS
      end

      specify do
        @connection.generate_all([[:inner, 'abc']]).should == [[:foo, <<-EOS]]
          tag(:div) { 'abc' }
        EOS
      end
    end
  end
end
