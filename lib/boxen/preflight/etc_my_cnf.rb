require "boxen/preflight"

class Boxen::Preflight::EtcMyCnf < Boxen::Preflight
  def run
    abort "You have an /etc/my.cnf file.",
      "This will confuse The Setup's MySQL a lot. Please remove it."
  end

  def ok?
    !File.file? "/etc/my.cnf"
  end
end
