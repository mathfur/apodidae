# -*- encoding: utf-8 -*-
require "spec_helper"

shared_examples_for 'Rachis' do
  describe '#initialize' do
    specify { subject.elems.should == {:html_id => 'foo_table'} }
  end

  describe '#[]' do
    it 'get one value of @elemes' do
      subject[:html_id].should == 'foo_table'
    end
  end
end

describe Apodidae::Rachis do
  subject { Apodidae::Rachis.new(html_id: 'foo_table') }

  it_should_behave_like 'Rachis'
end

describe Apodidae::Rachis do
  subject { Apodidae::Rachis.new(<<-EOS) }
    html_id 'foo_table'
  EOS

  it_should_behave_like 'Rachis'
end
