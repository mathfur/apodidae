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

    describe 'when rachis have right name' do
      before { @rachis = Apodidae::Rachis.new(:table,html_id: 'foo_table') }
      subject { @combine = Apodidae::Combine.new([@barb], @rachis) }

      it 'keys in barb statement are replaced by substitute block' do
        subject.instance_variable_get(:@result).should == <<EOS
html do
  tag :table, id: 'foo_table'  do
  end
end
EOS
      end
    end

    describe 'when rachis have wrong barb name' do
      before { @rachis = Apodidae::Rachis.new(:wrong_barb_name,html_id: 'foo_table') }
      specify { Proc.new { Apodidae::Combine.new([@barb], @rachis) }.should raise_error(RuntimeError) }
    end
  end
end
