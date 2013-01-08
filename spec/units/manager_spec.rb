# -*- encoding: utf-8 -*-

require "spec_helper"

describe Apodidae::Manager do
  before do
    Apodidae::Barb.clear_all_barbs
  end

  shared_examples_for 'Manager' do
    describe '#initialize' do
      specify do
        @manager.result.find{|k, v| k.label == :abc}.last.should be_equal_ignoring_spaces(<<-EOS)
          tag(:div) { 'abc' }
        EOS
      end
    end

    describe "#write_to" do
      describe "when the result of combining rachis and barb is form" do
        before do
          @relative_fname = "app/views/words/edit.html.erb"
          @output_dir1 = "#{BASE_DIR}/tmp/output"
          @output_dir2 = "#{BASE_DIR}/tmp/output2"

          FileUtils.rm_rf([@output_dir1, @output_dir2])

          @manager.generate
        end

        describe "when tmp/output is specified" do
          it "output html to tmp/output/app/views/words/edit.html.erb" do
            target = "#{@output_dir1}/#{@relative_fname}"
            @manager.write_to(Apodidae::Edge.new(:abc) => target)

            File.read(target).should be_equal_ignoring_spaces <<-EOS
              tag(:div) { 'abc' }
            EOS

            File.exist?("#{@output_dir2}/#{@relative_fname}").should be_false
          end
        end

        describe "when tmp/output2 is specified" do
          it "output html to tmp/output2/app/views/words/edit.html.erb" do
            target = "#{@output_dir1}/#{@relative_fname}"
            @manager.write_to(Apodidae::Edge.new(:abc) => target)

            File.read(target).should be_equal_ignoring_spaces <<-EOS
              tag(:div) { 'abc' }
            EOS
          end
        end
      end
    end
  end

  describe 'data specify by string' do
    before do
      @manager = Apodidae::Manager.new
      @manager.add_barb_from_string(:sample_barb, <<-EOS)
        #-->> gsub_by(Edge.new(:inner) => 'hello') do
        #-->> output_to Edge.new(:foo) do
          tag(:div) { 'hello' }
        #-->> end
        #-->> end
      EOS

      @manager.set_connection_from_string(<<-EOS)
        abc(:foo, :sample_barb) do
          inner(:str1)
        end
      EOS
      @manager.add_rachis(Apodidae::Edge.new(:str1) => 'abc')
      @manager.generate
    end

    it_should_behave_like 'Manager'
  end

  describe 'data read form file' do
    before do
      @manager = Apodidae::Manager.new

      Dir.mktmpdir do |tempdir|
        open("#{tempdir}/sample_barb.barb", 'w'){|f| f.write <<-EOS }
          #-->> gsub_by(Edge.new(:inner) => 'hello') do
          #-->> output_to Edge.new(:foo) do
            tag(:div) { 'hello' }
          #-->> end
          #-->> end
        EOS

        @manager.add_barb_from_file(tempdir)
      end

      Dir.mktmpdir do |tempdir|
        tempfile = Tempfile.new(['connection', '.rb'], tempdir)
        tempfile.write(<<-EOS)
          abc(:foo, :sample_barb) do
            inner(:str1)
          end
        EOS
        tempfile.close

        @manager.set_connection_from_file(tempfile.path)
      end

      Dir.mktmpdir do |tempdir|
        tempfile = Tempfile.new(['rachis', '.rachis'], tempdir)
        tempfile.write(<<-EOS)
          str1 'abc'
        EOS
        tempfile.close

        @manager.add_rachis_from_file(tempdir)
      end
      @manager.generate
    end

    it_should_behave_like 'Manager'
  end
end
