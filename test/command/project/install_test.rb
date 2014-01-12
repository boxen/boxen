require "boxen/command/project/install"
require "tmpdir"

describe Boxen::Command::Project::Install do
  before do
    @config = mock("config")
  end

  describe "#run" do
    before do
      Boxen::Command.expects(:invoke).with('run', @config)
    end

    it "installs a single project" do
      Dir.mktmpdir { |dir|
        @config.stubs(:repodir).returns(dir)
        Boxen::Command::Project::Install.new(@config, 'awesome-project').run

        projects = File.read("#{dir}/.projects")
        assert_equal projects, "awesome-project"
      }
    end

    it "installs multiple projects" do
      Dir.mktmpdir { |dir|
        @config.stubs(:repodir).returns(dir)
        Boxen::Command::Project::Install.new(@config, 'awesome-project', 'better-project').run

        projects = File.read("#{dir}/.projects")
        assert_equal projects, "awesome-project,better-project"
      }
    end
  end
end
