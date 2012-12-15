# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae do
  describe '#initialize' do
    before do
      @barb = Apodidae::Barb.new(:table,<<EOS)
substitute(
  :users_table => :html_id
)
html do
  tag :table, id: 'users_table'  do
  end
end
EOS
    end

    describe 'The first argument is :table and the second is {html_id: "foo_table"}' do
      before do
        @rachis = Apodidae::Rachis.new(:table,html_id: 'foo_table')
      end

      subject do
        @combine = Apodidae::Combine.new([@barb], @rachis)
      end

      specify do
        subject.instance_variable_get(:@result).should == <<EOS
html do
  tag :table, id: 'foo_table'  do
  end
end
EOS
      end
    end

    describe 'not existing barb name is specified' do
      before do
        @rachis = Apodidae::Rachis.new(:table_wrong,html_id: 'foo_table')
      end

      specify do
        Proc.new do
          @combine = Apodidae::Combine.new([@barb], @rachis)
        end.should raise_error(RuntimeError)
      end
    end
  end
end
