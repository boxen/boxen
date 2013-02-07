require "boxen/test"
require "boxen/project"

class BoxenProjectTest < Boxen::Test
  def test_initialize
    project = Boxen::Project.new "foo"
    assert_equal "foo", project.dir
  end

  def test_name
    project = Boxen::Project.new "foo/bar/baz"
    assert_equal "baz", project.name
  end
end
