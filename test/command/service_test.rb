require "boxen/command/service"

describe Boxen::Command::Service do
  before do
    @config = Minitest::Mock.new
  end

  describe "#run" do
    before do
      Boxen::Service.stubs(:list).returns([
                                           mock("service", :name => "foo"),
                                           mock("service", :name => "bar")
                                          ])
    end

    it "displays the list of services we know about" do
      stdout, _ = capture_io do
        Boxen::Command::Service.new(@config).run
      end

      assert_equal stdout, <<-EOS
Boxen manages the following services:

    foo
    bar
EOS
    end
  end

  describe "#services" do
    before do
      @foobar = mock()
    end

    describe "given args" do
      before do
        Boxen::Service.stubs(:new).with("foobar").returns(@foobar)
      end

      it "collects services based on args" do
        assert_equal [@foobar], Boxen::Command::Service.new(@config, "foobar").services
      end
    end

    describe "given no args" do
      before do
        Boxen::Service.stubs(:list).returns([@foobar])
      end

      it "collects all services" do
        assert_equal [@foobar], Boxen::Command::Service.new(@config).services
      end
    end
  end
end
