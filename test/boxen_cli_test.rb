require "boxen/test"
require "boxen/cli"

class BoxenCLITest < Boxen::Test
  def test_initialize
    config = Boxen::Config.new
    flags  = mock

    cli = Boxen::CLI.new config, flags

    assert_equal config, cli.config
    assert_equal flags, cli.flags
    assert_equal config, cli.puppet.config
    
    assert_equal config, cli.report.config
    assert_equal config, cli.report.checkout.config
    assert_equal cli.puppet, cli.report.puppet
  end
end
