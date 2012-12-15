# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Rachis do
  subject { Apodidae::Rachis.new(:table,html_id: 'foo_table') }

  describe '#initialize' do
    specify { subject.barb_name.should == 'table' }
    specify { subject.elems.should == {'html_id' => 'foo_table'} }
  end

  describe '#[]' do
    it 'get one value of @elemes' do
      subject['html_id'].should == 'foo_table'
    end
  end
end
