require "boxen/command/project"

describe Boxen::Command::Project do
  before do
    @config = mock("config")
  end

  describe "#run" do
    before do
      @config.stubs(:projects).returns([
        mock("project-a", :name => "puppet-boxen"),
        mock("project-b", :name => "puppet-ruby")
      ])
    end

    it "displays the projects we know about" do
      stdout, _ = capture_io do
        Boxen::Command::Project.new(@config).run
      end

      assert_equal stdout, <<-EOS
Boxen knows about the following projects:

    puppet-boxen
    puppet-ruby

You can install any of them by running \"boxen project:install <project>\"

EOS
    end
  end
end
