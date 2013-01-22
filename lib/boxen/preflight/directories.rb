require "boxen/preflight"
require "boxen/util"

class Boxen::Preflight::Directories < Boxen::Preflight
  def ok?
    homedir_directory_exists? &&
      homedir_owner == config.user &&
      homedir_group == 'staff'
  end

  def run
    Boxen::Util.sudo("/bin/mkdir", "-p", config.homedir) &&
      Boxen::Util.sudo("/usr/sbin/chown", "#{config.user}:staff", config.homedir)
  end

  private
  def homedir_directory_exists?
    File.directory?(config.homedir)
  end

  def homedir_owner
    Etc.getpwuid(homedir_stat.uid).name
  end

  def homedir_group
    Etc.getgrgid(homedir_stat.gid).name
  end

  def homedir_stat
    @homedir_stat ||= File.stat(config.homedir)
  end
end
