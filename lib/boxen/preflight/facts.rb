require "fileutils"
require "pathname"

require "boxen/preflight"

class Boxen::Preflight::Facts < Boxen::Preflight
  def ok?
    write_facts

    true
  end

  def run
  end

  private

  def facter_d
    Pathname.new("#{config.homedir}/facts.d")
  end

  def write_facts
    FileUtils.mkdir_p facter_d

    write_fact "offline", config.offline?
  end

  def write_fact(name, value)
    File.open("#{facter_d}/#{name}.txt", "w") do |f|
      f.write "#{name}=#{value}\n"
    end

    puts "    --> Setting global fact `#{name}` to `#{value}`" if config.debug?
  end

end
