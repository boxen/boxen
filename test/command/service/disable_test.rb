require "boxen/command/service/disable"

describe Boxen::Command::Service::Disable do
  describe "given arguments" do
    before do
      @config = mock("config")
      @single_c_thread = mock("service",
                              :name    => "single_c_thread",
                              :disable => true)

      Boxen::Service.stubs(:new).with("single_c_thread").returns(@single_c_thread)
    end

    it "should disable the service" do
      stdout, _ = capture_io do
        Boxen::Command::Service::Disable.new(@config, "single_c_thread").run
      end

      assert_equal stdout, "Disabling service: single_c_thread\n"
    end
  end

  describe "given no arguments" do
    before do
      @config = mock("config")
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
      stdout, _ = capture_io do
        Boxen::Command::Service::Disable.new(@config).run
      end

      assert_equal stdout, <<-EOS
Disabling service: single_c_thread
Disabling service: many_pthreads
EOS
    end
  end
end
