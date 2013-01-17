# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Connection do
  before do
    Apodidae::Barb.clear_all_barbs
    Apodidae::Inject.clear_cache
  end

  describe '#initialize' do
    before do
      @barb = Apodidae::Barb.new('sample_barb', <<-EOS)
        #-->> gsub_by(Edge.new(:inner) => 'value') do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'value' }
        #-->> end
        #-->> end
      EOS

      @barb2 = Apodidae::Barb.new('convert_to_html', <<-EOS)
        #-->> gsub_by(Edge.new(:input, :prehtml) => 'Prehtml_src') do
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

  describe "create table" do
    specify do
      @table_barb = Apodidae::Barb.new("simple_table",<<-EOS)
        #-->> output_to Edge.new(:output_html) do
        tag(:table) do
          tag(:tr) do
            #-->> loop_by(Edge.new("collection_of_label_value_pairs.first.keys") => ['label']) do
            tag(:th) { 'label' }
            #-->> end
          end
          #-->> loop_by(Edge.new(:collection_of_label_value_pairs, [:range, {:html => :html}]) => ['label_value_pairs']) do
          tag(:tr) do
            #-->> loop_by(Edge.new(:label_value_pairs) => ['label', 'value']) do
            tag(:td) { 'value' }
            #-->> end
          end
          #-->> end
        end
        #-->> end
      EOS

      @conv_barb = Apodidae::Barb.new("convert_to_html",<<-EOS)
        #-->> gsub_by(Edge.new(:input, :prehtml) => 'Prehtml_src') do
        #-->> output_to Edge.new(:output, :html) do
        #--==   Prehtml.new(Prehtml_src).to_html(multiline: true)
        #-->> end
        #-->> end
      EOS

      @connection = Apodidae::Connection.new(<<-EOS)
        output_html(:output, :convert_to_html) do
          input(:output_html, :simple_table) do
            collection_of_label_value_pairs(:user_data)
          end
        end
      EOS

      @rachis = Apodidae::Rachis.new(<<-EOS)
        group :user_data, :labels => ['氏名', 'メールアドレス', '年齢'] do
          row 'Suzuki', 'suzuki@gmail.com', '29'
          row 'Sato',   'sato@gmail.com',   '30'
        end
      EOS

      @connection.generate(Apodidae::Edge.new(:output_html), @rachis).should be_equal_ignoring_spaces(<<-EOS)
        <table>
          <tr>
            <th>氏名</th>
            <th>メールアドレス</th>
            <th>年齢</th>
          </tr>
          <tr>
            <td>Suzuki</td>
            <td>suzuki@gmail.com</td>
            <td>29</td>
          </tr>
          <tr>
            <td>Sato</td>
            <td>sato@gmail.com</td>
            <td>30</td>
          </tr>
        </table>
      EOS
    end
  end

  describe "have a branch" do
    specify do
      @table_barb = Apodidae::Barb.new("2way",<<-EOS)
        #-->> output_to Edge.new(:output1) do
          #-->> gsub_by(Edge.new('arr.first') => 'first_val') do
          tag(:span){ 'first_val' }
          #-->> end
        #-->> end
        #-->> output_to Edge.new(:output2) do
          #-->> gsub_by(Edge.new('arr.last') => 'last_val') do
          tag(:div){ 'last_val' }
          #-->> end
        #-->> end
      EOS

      @connection = Apodidae::Connection.new(<<-EOS)
        output1(:output1, '2way#1') do
          arr(:arr)
        end

        output2(:output2, '2way#1')
      EOS

      @rachis = Apodidae::Rachis.new(<<-EOS)
        arr %w{foo bar baz}
      EOS

      @connection.generate(Apodidae::Edge.new(:output1), @rachis).should be_equal_ignoring_spaces "tag(:span){ 'foo' }"
      @connection.generate(Apodidae::Edge.new(:output2), @rachis).should be_equal_ignoring_spaces "tag(:div){ 'baz' }"
    end
  end
end
