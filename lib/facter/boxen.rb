require "json"
require "boxen/config"

config   = Boxen::Config.load
facts    = {}
factsdir = "#{config.homedir}/config/facts"
dot_boxen = "#{ENV['HOME']}/.boxen"

facts["github_login"]  = config.login
facts["github_email"]  = config.email
facts["github_name"]   = config.name
facts["github_token"]  = config.token

facts["boxen_home"]    = config.homedir
facts["boxen_srcdir"]  = config.srcdir
facts["boxen_repodir"] = config.repodir
facts["boxen_user"]    = config.user
facts["luser"]         = config.user # this is goin' away

Dir["#{config.homedir}/config/facts/*.json"].each do |file|
  facts.merge! JSON.parse File.read file
end

if File.exist? dot_boxen
  facts.merge! JSON.parse(File.read(dot_boxen))
end

facts.each { |k, v| Facter.add(k) { setcode { v } } }
