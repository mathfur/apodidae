# -*- encoding: utf-8 -*-
require "spec_helper"

describe Apodidae::Barb do
  describe do
    subject { Apodidae::Barb.new('foo',<<-EOS) }
        #-->> gsub_by(Edge.new(:inner_div) => 'hello') do
        #-->> output_to Edge.new(nil) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      EOS

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == nil }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :inner_div }
    specify { subject.right_edges.first.type.should == [:prehtml] }
  end

  describe 'blank statement' do
    subject do
      Apodidae::Barb.new(:foo, "")
    end

    specify { subject.erbed_contents.should == '' }
    specify { subject.left_edges.should == [] }
    specify { subject.right_edges.should == [] }
  end

  describe 'simple statement' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> gsub_by(Edge.new(:inner_div) => 'hello') do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by(Edge.new(:inner_div) => 'hello') do -%>
        <%- if Edge.new(:foo) == edge -%>
          tag(:div) { '<%= inner_div %>' }
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:foo), [[Apodidae::Edge.new(:inner_div), 'hello']]).should == <<-OUTPUT
          tag(:div) { 'hello' }
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.type.should == [:prehtml] }
  end

  describe 'too old barb' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        # apodidae_version: 0.0.0
        #-->> gsub_by(Edge.new(:inner_div) => 'hello') do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.min_version.should == '0.0.0'
      subject.max_version.should == '0.0.0'
      subject.should_not be_able_to_use
    end
  end

  describe 'available version barb' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        # apodidae_version: 0.0.1 <= 100.53.1
        #-->> gsub_by(Edge.new(:inner_div) => 'hello') do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.min_version.should == '0.0.1'
      subject.max_version.should == '100.53.1'
      subject.should be_able_to_use
    end
  end

  describe '2 output_to' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> gsub_by(Edge.new(:inner_div) => 'hello') do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end

        #-->> gsub_by(Edge.new(:inner_div2) => 'hello2') do
        #-->> output_to Edge.new(:bar) do
          tag(:span) { 'hello2' }
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by(Edge.new(:inner_div) => 'hello') do -%>
        <%- if Edge.new(:foo) == edge -%>
          tag(:div) { '<%= inner_div %>' }
        <%- end -%>
        <%- end -%>

        <%- gsub_by(Edge.new(:inner_div2) => 'hello2') do -%>
        <%- if Edge.new(:bar) == edge -%>
          tag(:span) { '<%= inner_div2 %>' }
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:foo), [[Apodidae::Edge.new(:inner_div), 'abc'],[Apodidae::Edge.new(:inner_div), 'def']]).should be_equal_ignoring_spaces <<-OUTPUT
          tag(:div) { 'abc' }
      OUTPUT

      subject.evaluate(Apodidae::Edge.new(:bar), [[Apodidae::Edge.new(:inner_div), 'abc'],[Apodidae::Edge.new(:inner_div2), 'def']]).should be_equal_ignoring_spaces <<-OUTPUT
          tag(:span) { 'def' }
      OUTPUT
    end

    specify { subject.left_edges.size.should == 2 }
    specify { subject.left_edges[0].label.should == :foo }
    specify { subject.left_edges[0].type.should == [:prehtml] }
    specify { subject.left_edges[1].label.should == :bar }
    specify { subject.left_edges[1].type.should == [:prehtml] }
  end

  describe do
    subject { Apodidae::Barb.new('foo',<<-EOS) }
        #-->> gsub_by(Edge.new(:eight, [:integer]) => 'x') do
        #-->> output_to Edge.new(:nine, [:integer]) do
        #--==   1+x
        #-->> end
        #-->> end
      EOS

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by(Edge.new(:eight, [:integer]) => 'x') do -%>
        <%- if Edge.new(:nine, [:integer]) == edge -%>
        <%=   1+eight %>
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:nine, [:integer]), [[Apodidae::Edge.new(:eight, [:integer]), 8]]).should == <<-OUTPUT
        9
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :nine }
    specify { subject.left_edges.first.type.should == [:integer] }
  end

  describe 'convert to html' do
    subject do
      Apodidae::Barb.new('convert_to_html', <<-EOS)
        #-->> gsub_by(Edge.new(:input, [:prehtml]) => 'Prehtml_src') do
        #-->> output_to Edge.new(:foo, :html) do
        #--==   Prehtml.new(Prehtml_src).to_html
        #-->> end
        #-->> end
      EOS
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- gsub_by(Edge.new(:input, [:prehtml]) => 'Prehtml_src') do -%>
        <%- if Edge.new(:foo, :html) == edge -%>
        <%=   Prehtml.new(input).to_html %>
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:foo, [:html]), [[Apodidae::Edge.new(:input, [:prehtml]), "tag(:div){ 'abc' }"]]).should == <<-OUTPUT
        <div>abc</div>
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :foo }
    specify { subject.left_edges.first.type.should == [:html] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [:prehtml] }
  end

  describe '1 loop_by' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> output_to Edge.new(:output) do
        #-->> loop_by(Edge.new(:input, {:str => :html}) => ['WORD', 'MEANING']) do
        tag(:dl) do
          tag(:dt) { 'WORD' }
          tag(:dd) { 'MEANING' }
        end
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- if Edge.new(:output) == edge -%>
        <%- input.each_with_index do |(k1_0_0, k1_0_1), i1| -%>
        tag(:dl) do
          tag(:dt) { '<%= k1_0_0 %>' }
          tag(:dd) { '<%= k1_0_1 %>' }
        end
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:output),
        [[Apodidae::Edge.new(:input),{'WWW' => 'World Wide Web'}]]
      ).should == <<-OUTPUT
        tag(:dl) do
          tag(:dt) { 'WWW' }
          tag(:dd) { 'World Wide Web' }
        end
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :output }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [{:str => :html}] }
  end

  describe '2 loop_by' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> output_to Edge.new(:output) do
        tag(:table) do
          #-->> loop_by(Edge.new(:input, [:range,{:html => :html}]) => ['row', '__i__']) do
          tag(:tr) do
            #-->> loop_by(Edge.new(:row) => ['name', 'Suzuki']) do
            tag(:td) { 'Suzuki' }
            #-->> end
          end
          #-->> end
        end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- if Edge.new(:output) == edge -%>
        tag(:table) do
          <%- input.each_with_index do |(k1_0_0), i1| -%>
          tag(:tr) do
            <%- k1_0_0.each_with_index do |(k2_0_0, k2_0_1), i2| -%>
            tag(:td) { '<%= k2_0_1 %>' }
            <%- end -%>
          end
          <%- end -%>
        end
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:output), [[Apodidae::Edge.new(:input),eval(<<-INPUT)]]).should == <<-OUTPUT
        [
          {:name => 'Suzuki', :mail => 'suzuki@gmail.com'},
          {:name => 'Sato', :mail => 'sato@gmail.com'}
        ]
      INPUT
        tag(:table) do
          tag(:tr) do
            tag(:td) { 'Suzuki' }
            tag(:td) { 'suzuki@gmail.com' }
          end
          tag(:tr) do
            tag(:td) { 'Sato' }
            tag(:td) { 'sato@gmail.com' }
          end
        end
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :output }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [:range, {:html => :html}] }
  end

  describe 'insert procedure inside loop_by' do
    subject do
      Apodidae::Barb.new(:foo, <<-INPUT)
        #-->> output_to Edge.new(:output) do
        #-->> loop_by(Edge.new("input{|e| e.merge('abc' => 'def') }",{:str => :html}) => ['WORD', 'MEANING']) do
        tag(:dl) do
          tag(:dt) { 'WORD.{|e| e.upcase }' }
          tag(:dd) { 'MEANING' }
        end
        #-->> end
        #-->> end
      INPUT
    end

    specify do
      subject.erbed_contents.should == <<-OUTPUT
        <%- if Edge.new(:output) == edge -%>
        <%- proc{|e| e.merge('abc' => 'def') }[input].each_with_index do |(k1_0_0, k1_0_1), i1| -%>
        tag(:dl) do
          tag(:dt) { '<%= proc{|e| e.upcase }[k1_0_0] %>' }
          tag(:dd) { '<%= k1_0_1 %>' }
        end
        <%- end -%>
        <%- end -%>
      OUTPUT
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:output),
        [[Apodidae::Edge.new(:input),{'WWW' => 'World Wide Web'}]]
      ).should == <<-OUTPUT
        tag(:dl) do
          tag(:dt) { 'WWW' }
          tag(:dd) { 'World Wide Web' }
        end
        tag(:dl) do
          tag(:dt) { 'ABC' }
          tag(:dd) { 'def' }
        end
      OUTPUT
    end

    specify { subject.left_edges.size.should == 1 }
    specify { subject.left_edges.first.label.should == :output }
    specify { subject.left_edges.first.type.should == [:prehtml] }

    specify { subject.right_edges.size.should == 1 }
    specify { subject.right_edges.first.label.should == :input }
    specify { subject.right_edges.first.type.should == [{:str => :html}] }
  end

  describe 'table with rb_block' do
    subject do
      Apodidae::Barb.new(:table_with_rb_block, <<-EOS)
        #-->> output_to Edge.new(:output) do
        tag(:table) do
          #-->> gsub_by(Edge.new(:instance_name) => 'user_', Edge.new("instance_name.pluralize") => 'users') do
          rb_block("@users.each", "user_") do
            tag(:tr) do
              #-->> loop_by(Edge.new("hashs") => ['column']) do
              tag(:th){ 'column.{|e| e[:label] }' }
              #-->> end
            end
            tag(:tr) do
              #-->> loop_by(Edge.new("hashs") => ['row']) do
              tag(:td, :width => row.{|e| e[:width] }){ row.{|e| e[:rb_statement] } }
              #-->> end
            end
          end
          #-->> end
        end
        #-->> end
      EOS
    end

    specify do
      pending "上記row.{|e| .. の部分は#72対応後にrow:のように修正する"
    end

    specify do
      subject.erbed_contents.should be_equal_ignoring_spaces <<-EOS
        <%- if Edge.new(:output) == edge -%>
        tag(:table) do
          <%- gsub_by(Edge.new(:instance_name) => 'user_', Edge.new("instance_name.pluralize") => 'users') do -%>
          rb_block("@<%= proc{|e| e.pluralize }[instance_name] %>.each", "<%= instance_name %>") do
            tag(:tr) do
              <%- hashs.each_with_index do |(k2_0_0), i2| -%>
              tag(:th){ '<%= proc{|e| e[:label] }[k2_0_0] %>' }
              <%- end -%>
            end
            tag(:tr) do
              <%- hashs.each_with_index do |(k2_0_0), i2| -%>
              tag(:td, :width => <%= proc{|e| e[:width] }[k2_0_0] %>){ <%= proc{|e| e[:rb_statement] }[k2_0_0] %> }
              <%- end -%>
            end
          end
          <%- end -%>
        end
        <%- end -%>
      EOS
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:output), [
        [Apodidae::Edge.new(:instance_name), 'entry'],
        [Apodidae::Edge.new(:hashs), [
          {:label => 'タイトル', :rb_statement => %Q!rb("entry.title")!,    :width => 200},
          {:label => 'カテゴリ', :rb_statement => %Q!rb("entry.category")!, :width => 100},
        ]]
      ]).should be_equal_ignoring_spaces <<-EOS
        tag(:table) do
          rb_block("@entries.each", "entry") do
            tag(:tr) do
              tag(:th){ 'タイトル' }
              tag(:th){ 'カテゴリ' }
            end
            tag(:tr) do
              tag(:td, :width => 200){ rb("entry.title") }
              tag(:td, :width => 100){ rb("entry.category") }
            end
          end
        end
      EOS
    end
  end

  describe do
    subject do
      Apodidae::Barb.new(:show, <<-EOS)
        #-->> gsub_by(Edge.new(:instance_name) => 'useR', Edge.new("instance_name.pluralize") => 'users') do
          #-->> output_to Edge.new(:route) do
          resources :users
          #-->> end

          #-->> output_to Edge.new(:controller) do
          def show
            @useR = useR...camelize.find(params[:id])

            respond_to do |format|
              format.html
              format.json { render json: @useR }
            end
          end
          #-->> end

          #-->> output_to Edge.new(:view) do
            tag(:p, :id=>"notice"){ rb("notice") }

            #-->> loop_by(Edge.new(:column) => ['mail']) do
            tag(:p) do
              tag(:b){ "mail...camelize:" }
              rb("@useR.mail")
            end

            #-->> end
            rb("link_to 'Edit', edit_useR_path(@useR)")
            rb("link_to 'Back', users_path")
          #-->> end
        #-->> end
      EOS
    end

    specify do
      subject.erbed_contents.should be_equal_ignoring_spaces <<-EOS
        <%- gsub_by(Edge.new(:instance_name) => 'useR', Edge.new("instance_name.pluralize") => 'users') do -%>
          <%- if Edge.new(:route) == edge -%>
          resources :<%= proc{|e| e.pluralize }[instance_name] %>
          <%- end -%>

          <%- if Edge.new(:controller) == edge -%>
          def show
            @<%= instance_name %> = <%= instance_name.camelize %>.find(params[:id])

            respond_to do |format|
              format.html
              format.json { render json: @<%= instance_name %> }
            end
          end
          <%- end -%>

          <%- if Edge.new(:view) == edge -%>
            tag(:p, :id=>"notice"){ rb("notice") }

            <%- column.each_with_index do |(k2_0_0), i2| -%>
            tag(:p) do
              tag(:b){ "<%= k2_0_0.camelize %>:" }
              rb("@<%= instance_name %>.<%= k2_0_0 %>")
            end

            <%- end -%>
            rb("link_to 'Edit', edit_<%= instance_name %>_path(@<%= instance_name %>)")
            rb("link_to 'Back', <%= proc{|e| e.pluralize }[instance_name] %>_path")
          <%- end -%>
        <%- end -%>
      EOS
    end

    specify do
      subject.evaluate(Apodidae::Edge.new(:route), [
        [Apodidae::Edge.new(:instance_name), 'entry'],
        [Apodidae::Edge.new(:column), %w{title contents}],
      ]).should be_equal_ignoring_spaces <<-EOS
        resources :entries
      EOS

      subject.evaluate(Apodidae::Edge.new(:controller), [
        [Apodidae::Edge.new(:instance_name), 'entry'],
        [Apodidae::Edge.new(:column), %w{title contents}],
      ]).should be_equal_ignoring_spaces <<-EOS
        def show
          @entry = Entry.find(params[:id])

          respond_to do |format|
            format.html
            format.json { render json: @entry }
          end
        end
      EOS

      subject.evaluate(Apodidae::Edge.new(:view), [
        [Apodidae::Edge.new(:instance_name), 'entry'],
        [Apodidae::Edge.new(:column), %w{title contents}],
      ]).should be_equal_ignoring_spaces <<-EOS
        tag(:p, :id=>"notice"){ rb("notice") }

        tag(:p) do
          tag(:b){ "Title:" }
          rb("@entry.title")
        end

        tag(:p) do
          tag(:b){ "Contents:" }
          rb("@entry.contents")
        end

        rb("link_to 'Edit', edit_entry_path(@entry)")
        rb("link_to 'Back', entries_path")
      EOS
    end
  end
end
