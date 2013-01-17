# -*- encoding: utf-8 -*-
require "spec_helper"

describe 'apodidae command' do
  describe 'with --help option' do
    it "output help statement" do
      execute_apodidae_command("--help").should == <<EOS
Usage: apodidae [options]
    -w, --watch     compile automatically when template or source is changed.
EOS
    end
  end

  describe 'with -h option' do
    it "output help statement" do
      execute_apodidae_command("-h").should == <<EOS
Usage: apodidae [options]
    -w, --watch     compile automatically when template or source is changed.
EOS
    end
  end

  describe "with --version option" do
    it "output version number" do
      execute_apodidae_command("--version").strip.should == '0.0.0'
    end
  end

  describe "with -v option" do
    it "output version number" do
      execute_apodidae_command("-v").strip.should == '0.0.0'
    end
  end

  describe "with --watch option" do
    it "output 'before implementation'" do
      execute_apodidae_command("--watch").should be_include('before implementation')
    end
  end

  describe "with -w option" do
    it "output 'before implementation'" do
      execute_apodidae_command("-w").should be_include('before implementation')
    end
  end

  describe "with --output-dir" do
    describe "when tmp/output is specified" do
      it "output html to tmp/output/app/views/words/edit.html.erb" do
        output_file = "#{BASE_DIR}/tmp/output/foo"
        FileUtils.rm_rf(output_file)

        Dir.mktmpdir do |barb_dir|
          Dir.mktmpdir do |connection_dir|
            Dir.mktmpdir do |rachis_dir|
              open("#{barb_dir}/sample_barb.barb", 'w'){|f| f.write(<<-EOS) }
                #-->> gsub_by(Edge.new(:inner) => 'hello') do
                #-->> output_to Edge.new(:foo) do
                  tag(:div) { 'hello' }
                #-->> end
                #-->> end
              EOS

              open("#{barb_dir}/convert_to_html.barb", 'w'){|f| f.write(<<-EOS) }
                #-->> gsub_by(Edge.new(:input, :prehtml) => 'Prehtml_src') do
                #-->> output_to Edge.new(:baz, :html) do
                #--==   Prehtml.new(Prehtml_src).to_html
                #-->> end
                #-->> end
              EOS

              connection_file = Tempfile.new(['connection', '.rb'], connection_dir)
              connection_file.write(<<-EOS)
                abc(:baz, :convert_to_html) do
                  input(:foo, :sample_barb) do
                    inner(:str1)
                  end
                end
              EOS
              connection_file.close

              rachis_file = Tempfile.new(['rachis', '.rachis'], rachis_dir)
              rachis_file.write(<<-EOS)
                str1 'abc'
              EOS
              rachis_file.close

              execute_apodidae_command([
                "--barb-dir=#{barb_dir}",
                "--rachis-dir=#{rachis_dir}",
                "--connection-file=#{connection_file.path}",
                "--output-file=abc:#{output_file}"
              ])
              File.read(output_file).should be_equal_ignoring_spaces <<-EOS
                <div>abc</div>
              EOS
            end
          end
        end
      end
    end
  end

  describe "with --output-dir" do
    describe "when tmp/output is specified" do
      it "output html to tmp/output/app/views/words/edit.html.erb" do
        output_file = "#{BASE_DIR}/tmp/output/foo"
        output_file2 = "#{BASE_DIR}/tmp/output/bar"
        FileUtils.rm_rf([output_file, output_file2])

        Dir.mktmpdir do |barb_dir|
          Dir.mktmpdir do |connection_dir|
            Dir.mktmpdir do |rachis_dir|
              open("#{barb_dir}/foo.barb", 'w'){|f| f.write(<<-EOS) }
                #-->> gsub_by(Edge.new(:inner) => 'hello') do
                #-->> output_to Edge.new(:foo) do
                  tag(:div){ 'hello' }
                #-->> end
                #-->> end
              EOS

              connection_file = Tempfile.new(['connection', '.rb'], connection_dir)
              connection_file.write(<<-EOS)
                abc(:foo, :foo) do
                  inner(:str1)
                end
                xyz(:foo, :foo) do
                  inner(:str2)
                end
              EOS
              connection_file.close

              rachis_file = Tempfile.new(['rachis', '.rachis'], rachis_dir)
              rachis_file.write(<<-EOS)
                str1 'abc'
                str2 'xyz'
              EOS
              rachis_file.close

              execute_apodidae_command([
                "--barb-dir=#{barb_dir}",
                "--rachis-dir=#{rachis_dir}",
                "--connection-file=#{connection_file.path}",
                "--output-file=abc:#{output_file},xyz:#{output_file2}"
              ])
              File.read(output_file).should be_equal_ignoring_spaces "tag(:div){ 'abc' }"
              File.read(output_file2).should be_equal_ignoring_spaces "tag(:div){ 'xyz' }"
            end
          end
        end
      end
    end
  end

  describe "without options" do
    it "output html to current directory" do
      pending
    end
  end

  def execute_apodidae_command(*args)
    args = [args].flatten
    stdout_string = nil
    IO.popen(["#{BASE_DIR}/bin/apodidae"]+args, 'r+') do |io|
      stdout_string = io.read if io
    end
    stdout_string
  end
end
