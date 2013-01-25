# -*- encoding: utf-8 -*-
require "spec_helper"

describe 'apodidae command' do
  describe 'with --help option' do
    it "output help statement" do
      execute_apodidae_command("--help").should be_include("Usage: apodidae [options]")
    end
  end

  describe 'with -h option' do
    it "output help statement" do
      execute_apodidae_command("--help").should be_include("Usage: apodidae [options]")
    end
  end

  describe "with --version option" do
    it "output version number" do
      execute_apodidae_command("--version").strip.should == '0.0.3'
    end
  end

  describe "with -v option" do
    it "output version number" do
      execute_apodidae_command("-v").strip.should == '0.0.3'
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

  describe "with --list-barbs option" do
    it "output 2 barb" do
      prepare_files do |barb_dir, rachis_dir, connection_dir|
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

        execute_apodidae_command("--list-barbs=#{barb_dir}").should be_equal_ignoring_spaces(<<-EOS)
          convert_to_html
            input@prehtml
            ->
            baz@html
          sample_barb
            inner@prehtml
            ->
            foo@prehtml
        EOS
      end
    end
  end

  output_file_name1 = "tmp/output/foo"
  output_file_name2 = "tmp/output/bar"

  describe "with --output-file" do
    describe "when tmp/output is #{output_file_name1}" do
      it "output html to #{output_file_name1}" do
        FileUtils.rm_rf(output_file_name1)

        prepare_files do |barb_dir, rachis_dir, connection_dir|
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
            "--output-file=abc:#{output_file_name1}"
          ])
          File.read(output_file_name1).should be_equal_ignoring_spaces <<-EOS
            <div>abc</div>
          EOS
        end
      end
    end
  end

  describe "with --output-file" do
    describe "when the target of 'abc' is #{output_file_name1} and the target of 'xyz' is #{output_file_name2}" do
      it "output 'abc' to #{output_file_name1} and 'xyz' to #{output_file_name2}" do
        FileUtils.rm_rf(output_file_name1)

        output_file2 = Tempfile.new(['output_file_name2', '.txt'], File.dirname(output_file_name2))
        output_file2.write(<<-EOS)
           {{{
           #123
           }}}
        EOS
        output_file2.close

        prepare_files do |barb_dir, rachis_dir, connection_dir|
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
            "--output-file=abc:#{output_file_name1},xyz:#{output_file2.path}#123"
          ])
          File.read(output_file_name1).should be_equal_ignoring_spaces "tag(:div){ 'abc' }"
          File.read(output_file2.path).should be_equal_ignoring_spaces <<-EOS
            {{{
            tag(:div){ 'xyz' }
            }}}
          EOS
        end
      end
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
