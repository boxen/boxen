require "boxen/command/service/enable"

describe Boxen::Command::Service::Enable do
  describe "given arguments" do
    before do
      @config = mock("config")
      @single_c_thread = mock("service",
                              :name   => "single_c_thread",
                              :enable => true)

      Boxen::Service.stubs(:new).with("single_c_thread").returns(@single_c_thread)
    end

    it "should enable the service" do
      stdout, _ = capture_io do
        Boxen::Command::Service::Enable.new(@config, "single_c_thread").run
      end

      assert_equal stdout, "Enabling service: single_c_thread\n"
    end
  end

  describe "given no arguments" do
    before do
      @config = mock("config")
      @single_c_thread = mock("service",
                              :name   => "single_c_thread",
                              :enable => true)

      @many_pthreads = mock("service",
                            :name   => "many_pthreads",
                            :enable => true)

      Boxen::Service.stubs(:list).
        returns([@single_c_thread, @many_pthreads])
    end

    it "should enable all services" do
      stdout, _ = capture_io do
        Boxen::Command::Service::Enable.new(@config).run
      end

      assert_equal stdout, <<-EOS
Enabling service: single_c_thread
Enabling service: many_pthreads
EOS
    end
  end
end
