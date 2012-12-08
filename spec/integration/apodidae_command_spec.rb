require "spec_helper"

describe 'apodidae command' do
  # apodidaeコマンドを実行できる
  it "can be run" do
    IO.popen(["#{BASE_DIR}/bin/apodidae"],  'r+')
  end
end
