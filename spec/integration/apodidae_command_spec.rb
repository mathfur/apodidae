# -*- encoding: utf-8 -*-
require "spec_helper"

describe 'apodidae command' do
  # apodidaeコマンドを実行できる
  it "can be run" do
    IO.popen(["#{BASE_DIR}/bin/apodidae"],  'r+')
  end

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
    before do
      @relative_fname = "app/views/words/edit.html.erb"
    end

    describe "when tmp/output is specified" do
      it "output html to tmp/output/app/views/words/edit.html.erb" do
        @output_dir = "#{BASE_DIR}/tmp/output"
        @output_fname = "#{@output_dir}/#{@relative_fname}"
        FileUtils.rm_rf(@output_dir)

        execute_apodidae_command("--output-dir=#{@output_dir}")

        File.read(@output_fname).should == <<EOS
<%= form_for(@word) do |f| %>
  <div class="field">
    <%= f.label :name %><br />
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :mail %><br />
    <%= f.text_field :mail %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
EOS
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
