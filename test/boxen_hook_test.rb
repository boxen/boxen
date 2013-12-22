require "boxen/hook"

class DatHook < Boxen::Hook
  def enabled?
    true
  end

  def run
    puts "yolo"
  end
end

describe Boxen::Hook do

  it "registers hooks and executes them" do
    Boxen::Hook.register DatHook

    stdout, stderr = capture_io do
      Boxen::Hook.run
    end

    assert_equal stdout, "yolo"
  end

end
