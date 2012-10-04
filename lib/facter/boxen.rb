require "json"
require "boxen/config"

config   = Boxen::Config.load
facts    = {}
factsdir = File.join config.homedir, "config", "facts"

facts["github_login"]  = config.login
facts["github_email"]  = config.email
facts["github_name"]   = config.name
facts["github_token"]  = config.token

facts["boxen_home"]    = config.homedir
facts["boxen_srcdir"]  = config.srcdir
facts["boxen_repodir"] = config.repodir
facts["luser"]         = config.user

Dir["#{config.homedir}/config/facts/*.json"].each do |file|
  facts.merge! JSON.parse File.read file
end

facts.each { |k, v| Facter.add(k) { setcode { v } } }
