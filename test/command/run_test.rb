require "boxen/command/run"

describe Boxen::Command::Run do
  before do
    @config = mock("config")
  end

  it "should enable puppet reports" do
    command = Boxen::Command::Run.new(@config, "--report")
    assert command.report?
  end
  it "should enable puppet profiling" do
    command = Boxen::Command::Run.new(@config, "--profile")
    assert command.profile?
  end

  it "should enable puppet's future parser" do
    command = Boxen::Command::Run.new(@config, "--future-parser")
    assert command.future_parser?
  end
end
