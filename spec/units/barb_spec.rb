# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae do
  describe 'when normal argument is specified' do
    subject { Apodidae::Barb.new('foo',<<EOS) }
substitute(
  :abc => 123
)
EOS
    specify { subject.name.should == "foo" }
    specify { subject.contents.should == <<EOS }
substitute(
  :abc => 123
)
EOS
    specify do
      subject.substitute_rules.should == {:abc => 123}
    end
  end

  describe 'when the contents have general methods' do
    subject { Apodidae::Barb.new('foo',<<EOS) }
substitute(
  :abc => 123
)
html do
end
EOS
    specify { subject.name.should == "foo" }
    specify { subject.contents.should == <<EOS }
substitute(
  :abc => 123
)
html do
end
EOS
  end
end
