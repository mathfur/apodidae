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

  describe "without options" do
    pending
#    it "output usage" do
#      execute_apodidae_command.should == <<EOS
#Usage: apodidae [options]
#    -w, --watch     compile automatically when template or source is changed.
#EOS
#    end
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
