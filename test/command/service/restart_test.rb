require "boxen/command/service/restart"


describe Boxen::Command::Service::Restart do
  describe "with args" do
    before do
      @single_c_thread = mock("service",
                              :name    => "single_c_thread",
                              :enable  => true,
                              :disable => true)

      Boxen::Service.stubs(:new).with("single_c_thread").returns(@single_c_thread)
    end

    it "should restart the service" do
      stdout, _ = capture_io do
        Boxen::Command::Service::Restart.new("single_c_thread").run
      end

      assert_equal stdout, "Restarting service: single_c_thread\n"
    end
  end

  describe "without args" do
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
      stdout, _ = capture_io do
        Boxen::Command::Service::Restart.new.run
      end

      assert_equal stdout, <<-EOS
Restarting service: single_c_thread
Restarting service: many_pthreads
EOS
    end
  end
end
