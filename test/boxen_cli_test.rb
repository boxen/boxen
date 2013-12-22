require "boxen/cli"

require "boxen/command_status"

describe Boxen::CLI do

  it "is a fancy way of reinvoking commands at this time" do
    Boxen::Command.expects(:invoke).with("foo").
      returns(Boxen::CommandStatus.new(0))

    Boxen::CLI.run("foo")
  end

end
