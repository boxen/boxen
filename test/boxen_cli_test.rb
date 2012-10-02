require "boxen/test"
require "boxen/cli"

class BoxenCLITest < Boxen::Test
  def test_initialize
    config = mock
    flags  = mock

    cli = Boxen::CLI.new config, flags

    assert_equal config, cli.config
    assert_equal flags, cli.flags
    assert_equal config, cli.puppet.config
  end
end
