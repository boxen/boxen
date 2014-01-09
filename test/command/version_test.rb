require "boxen/command/version"

describe Boxen::Command::Version do
  let(:instance) { Boxen::Command::Version.new(mock("config")) }

  it "writes the boxen version to standard out, duh" do
    instance.stubs(:version).returns("100.0.0")

    stdout, _ = capture_io do
      instance.run
    end

    assert_match "Boxen 100.0.0", stdout
  end
end
