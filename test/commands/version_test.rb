require "boxen/commands/version"

describe Boxen::Commands::VersionCommand do
  let(:instance) { Boxen::Commands::VersionCommand.new }

  it "writes the boxen version to standard out, duh" do
    instance.stubs(:version).returns("100.0.0")

    stdout, stderr = capture_io do
      instance.run
    end

    assert_match "Boxen 100.0.0", stdout
  end
end
