require 'boxen/test'
require 'boxen/preflight/directories'

class BoxenPreflightDirectoriesTest < Boxen::Test
  class TestConfig
    def user;    "foobar"; end
    def homedir; "foobar"; end
  end

  def setup
    @config = TestConfig.new
  end

  def test_not_okay_if_homedir_group_wrong
    directories = Boxen::Preflight::Directories.new(@config)
    directories.stubs(:homedir_group).returns(false)
    refute directories.ok?
  end

  def test_not_okay_if_homedir_owner_wrong
    directories = Boxen::Preflight::Directories.new(@config)
    directories.stubs(:homedir_owner).returns(false)
    refute directories.ok?
  end

  def test_not_okay_unless_homedir_exists
    directories = Boxen::Preflight::Directories.new(@config)
    directories.stubs(:homedir_directory_exists?).returns(false)
    refute directories.ok?
  end

  def test_okay_if_allchecks_fine
    directories = Boxen::Preflight::Directories.new(@config)
    directories.stubs(:homedir_directory_exists?).returns(true)
    directories.stubs(:homedir_owner).returns("foobar")
    directories.stubs(:homedir_group).returns("staff")

    assert directories.ok?
  end
end
