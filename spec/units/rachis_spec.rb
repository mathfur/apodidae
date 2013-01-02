# -*- encoding: utf-8 -*-
require "spec_helper"

shared_examples_for 'Rachis' do
  describe '#initialize' do
    specify { subject.elems.keys.should == [Apodidae::Edge.new(:html_id)] }
    specify { subject.elems.values.should == ['foo_table'] }
  end

  describe '#[]' do
    it 'get one value of @elemes' do
      subject[Apodidae::Edge.new(:html_id)].should == 'foo_table'
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

describe '' do
  subject do
    Apodidae::Rachis.new(<<-EOS)
      group :user_data do
        label '氏名', 'メールアドレス', '年齢'
        row 'Suzuki', 'suzuki@gmail.com', '29'
        row 'Sato',   'sato@gmail.com',   '30'
      end
    EOS
  end

  specify do
    subject[Apodidae::Edge.new(:user_data)].should == [
      [:label, '氏名',   'メールアドレス', '年齢'],
      [:row,   'Suzuki', 'suzuki@gmail.com', '29'],
      [:row,   'Sato',   'sato@gmail.com',   '30']
    ]
  end
end

describe do
  subject do
    Apodidae::Rachis.new(<<-EOS)
      group :user_data2, :labels => [:label, :statement, :width], :need_name => true do
        name '氏名', 'row.name', 150
        age  '年齢', 'row.age',  80
      end
    EOS
  end

  specify do
    subject[Apodidae::Edge.new(:user_data2)][0].should be_same_hash(
      {:name => :name, :label => '氏名', :statement => 'row.name', :width => 150})
    subject[Apodidae::Edge.new(:user_data2)][1].should be_same_hash(
      {:name => :age,  :label => '年齢', :statement => 'row.age',  :width => 80})
  end
end

describe do
  specify do
    Apodidae::Rachis.new(
      [[Apodidae::Edge.new(:str1), 'abc']])[Apodidae::Edge.new(:str1)].should == 'abc'
  end
end
