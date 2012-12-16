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
        subject.substitute_rules.should == {:abc => [123]}
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

      specify { subject.substitute_rules.should == {:abc => [15]} }
    end

    describe do
      it "labelありの場合" do
        pending
        subject { Apodidae::Barb.new('foo', <<-EOS) }
          substitute do
            __label def
            abc 123
          end
          html do
          end
          EOS
        specify { subject.name.should == 'foo' }
        specify { subject.substitute_rules.should == {:abc => {:def => 123}} }
              # abc.defのようにアクセスできるようにするべき?
      end
    end
  end
end
