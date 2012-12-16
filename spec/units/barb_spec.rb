# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae do
  describe '#initialize' do
    describe 'when normal argument is specified' do
      subject { Apodidae::Barb.new('foo',<<-EOS) }
        substitute do
          abc 123
        end
        EOS
      specify { subject.name.should == "foo" }
      specify { subject.contents.should == <<-EOS }
        substitute do
          abc 123
        end
        EOS
      specify do
        subject.substitute_rules.size.should == 1
        subject.substitute_rules.first._name_.should == 'abc'
        subject.substitute_rules.first[0].should == 123
      end
    end

    describe 'when the contents have general methods' do
      subject { Apodidae::Barb.new('foo',<<-EOS) }
        substitute do
          abc 123
        end
        html do
        end
        EOS
      specify { subject.name.should == "foo" }
      specify { subject.contents.should == <<-EOS }
        substitute do
          abc 123
        end
        html do
        end
        EOS
    end

    describe 'when the contents have general methods' do
      subject { Apodidae::Barb.new('foo',<<-EOS) }
        substitute do
          abc 123
        end
        html do
        end
        EOS
      specify { subject.name.should == "foo" }
      specify { subject.contents.should == <<-EOS }
        substitute do
          abc 123
        end
        html do
        end
        EOS
    end

    describe do
      subject do
        barb = Apodidae::Barb.new('foo', <<-EOS)
          substitute do
            abc x
          end
          EOS
        barb.add_rachis_attrs(:x => 15)
      end

      specify { subject.substitute_rules.size.should == 1 }
      specify { subject.substitute_rules.first._name_ == 'abc' }
      specify { subject.substitute_rules.first[0] == 15 }
    end
  end
end

describe Apodidae::SubstituteSandbox do
  describe "having no __label" do
    before do
      @substitute_sandbox = Apodidae::SubstituteSandbox.new
      @substitute_sandbox.instance_eval do
        row :x
      end
      @items = @substitute_sandbox.items
    end

    specify { @items.size.should == 1 }

    describe do
      subject { @items.first }
      specify { subject[0].should == :x }
      specify { subject[1].should be_nil }
      specify do
        Proc.new { subject.name }.should raise_error(RuntimeError)
        Proc.new { subject.agk }.should raise_error(RuntimeError)
      end
    end
  end

  describe "having __label in block" do
    before do
      @substitute_sandbox = Apodidae::SubstituteSandbox.new
      @substitute_sandbox.instance_eval do
        __label :name, :width
        row :age, 150
      end
      @items = @substitute_sandbox.items
    end

    specify { @items.size.should == 1 }

    describe do
      subject { @items.first }
      specify { subject[0].should == :age }
      specify { subject[1].should == 150 }
      specify { subject.name.should == :age }
      specify { subject.width.should == 150 }
    end
  end

  describe "having two __label in block" do
    before do
      @substitute_sandbox = Apodidae::SubstituteSandbox.new
      @substitute_sandbox.instance_eval do
        __label :name, :width
        row :age, 150

        __label :id, :inner
        list_item :users, 'Users'
      end
      @items = @substitute_sandbox.items
    end

    specify { @items.size.should == 2 }

    describe 'with first item' do
      subject { @items[0] }
      specify { subject[0].should == :age }
      specify { subject[1].should == 150 }
      specify { subject.name.should == :age }
      specify { subject.width.should == 150 }
    end

    describe 'with second item' do
      subject { @items[1] }
      specify { subject[0].should == :users }
      specify { subject[1].should == 'Users' }
      specify { subject.id.should == :users }
      specify { subject.inner.should == 'Users' }
    end
  end

  describe "having one __label and one item without __label in block" do
    before do
      @substitute_sandbox = Apodidae::SubstituteSandbox.new
      @substitute_sandbox.instance_eval do
        __label :name, :width
        row :age, 150

        list_item :users, 'Users'
      end
      @items = @substitute_sandbox.items
    end

    specify { @items.size.should == 2 }

    describe 'with first item' do
      subject { @items[0] }
      specify { subject[0].should == :age }
      specify { subject[1].should == 150 }
      specify { subject.name.should == :age }
      specify { subject.width.should == 150 }
    end

    describe 'with second item' do
      subject { @items[1] }
      specify { subject[0].should == :users }
      specify { subject[1].should == 'Users' }
      specify { Proc.new { subject.name }.should raise_error(RuntimeError) }
      specify { Proc.new { subject.width }.should raise_error(RuntimeError) }
    end
  end
end

describe Apodidae::SubstituteItem do
  context "when labels is specified" do
    subject { Apodidae::SubstituteItem.new('foo', [:name, :age], ['suzuki', 30]) }
    specify { subject._name_.should == 'foo' }
    specify { subject[0].should == 'suzuki' }
    specify { subject[1].should == 30 }

    specify { subject[:name].should == 'suzuki' }
    specify { subject.name.should == 'suzuki' }
  end

  context "when labels is not specified" do
    subject { Apodidae::SubstituteItem.new('foo', nil, ['suzuki', 30]) }
    specify { subject._name_.should == 'foo' }
    specify { subject[0].should == 'suzuki' }
    specify { subject[1].should == 30 }

    specify do
      Proc.new { subject[:name] }.should raise_error(RuntimeError)
    end
  end
end
