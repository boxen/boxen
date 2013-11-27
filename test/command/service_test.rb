require "boxen/command/service"

  def test_restart_services
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--restart-services')
    runner = Boxen::Runner.new config, flags

    services = Array.new(3) { mock('service') }
    services.each do |service|
      service.expects(:disable).once
      service.expects(:enable).once
    end
    Boxen::Service.stubs(:list).returns(services)

    assert_raises(SystemExit) do
      runner.process
    end
  end


  def test_list_services
    config = Boxen::Config.new
    flags  = Boxen::Flags.new('--list-services')
    runner = Boxen::Runner.new config, flags

    Boxen::Service.expects(:list).returns(%w[a list of services])

    assert_raises(SystemExit) do
      runner.process
    end
  end


describe Boxen::Command::Service do
  before do
    Boxen::Service.stubs(:list).returns([
                                         mock("service", :name => "foo"),
                                         mock("servivce", :name => "bar")
                                        ])
  end

  it "displays the list of services we know about" do
    stdout, stderr = capture_io do
      Boxen::Command::Service.new.run
    end

    assert_equal stdout, <<-EOS
Boxen manages the following services:

    foo
    bar
EOS
  end
end

describe Boxen::Command::Service::Enable do
  before do
    @single_c_thread = mock("service",
                            :enable => true)

    Boxen::Service.stubs(:new).with("single_c_thread").returns(@single_c_thread)
  end

  it "should enable the service" do
    stdout, stderr = capture_io do
      Boxen::Command::Service::Enable.new("single_c_thread").run
    end

    assert_equal stdout, "Enabling service: single_c_thread\n"
  end

end

describe Boxen::Command::Service::Disable do
  before do
    @single_c_thread = mock("service",
                            :disable => true)

    Boxen::Service.stubs(:new).with("single_c_thread").returns(@single_c_thread)
  end

  it "should disable the service" do
    stdout, stderr = capture_io do
      Boxen::Command::Service::Disable.new("single_c_thread").run
    end

    assert_equal stdout, "Disabling service: single_c_thread\n"
  end

end

describe Boxen::Command::Service::Restart do
  before do
    @single_c_thread = mock("service",
                            :enable  => true,
                            :disable => true)

    Boxen::Service.stubs(:new).with("single_c_thread").returns(@single_c_thread)
  end

  it "should restart the service" do
    stdout, stderr = capture_io do
      Boxen::Command::Service::Restart.new("single_c_thread").run
    end

    assert_equal stdout, "Restarting service: single_c_thread\n"
  end
end

describe Boxen::Command::Service::EnableAll do
  before do
    @single_c_thread = mock("service",
                            :name    => "single_c_thread",
                            :enable  => true)

    @many_pthreads = mock("service",
                          :name    => "many_pthreads",
                          :enable  => true)

    Boxen::Service.stubs(:list).
      returns([@single_c_thread, @many_pthreads])
  end

  it "should enable all services" do
    stdout, stderr = capture_io do
      Boxen::Command::Service::EnableAll.new.run
    end

    assert_equal stdout, <<-EOS
Enabling service: single_c_thread
Enabling service: many_pthreads
EOS
  end
end

describe Boxen::Command::Service::DisableAll do
  before do
    @single_c_thread = mock("service",
                            :name    => "single_c_thread",
                            :disable => true)

    @many_pthreads = mock("service",
                          :name    => "many_pthreads",
                          :disable => true)

    Boxen::Service.stubs(:list).
      returns([@single_c_thread, @many_pthreads])
  end

  it "should enable all services" do
    stdout, stderr = capture_io do
      Boxen::Command::Service::DisableAll.new.run
    end

    assert_equal stdout, <<-EOS
Disabling service: single_c_thread
Disabling service: many_pthreads
EOS
  end
end

describe Boxen::Command::Service::RestartAll do
  before do
    @single_c_thread = mock("service",
                            :name    => "single_c_thread",
                            :enable  => true,
                            :disable => true)

    @many_pthreads = mock("service",
                          :name    => "many_pthreads",
                          :enable  => true,
                          :disable => true)

    Boxen::Service.stubs(:list).
      returns([@single_c_thread, @many_pthreads])
  end

  it "should enable all services" do
    stdout, stderr = capture_io do
      Boxen::Command::Service::RestartAll.new.run
    end

    assert_equal stdout, <<-EOS
Restarting service: single_c_thread
Restarting service: many_pthreads
EOS
  end
end
