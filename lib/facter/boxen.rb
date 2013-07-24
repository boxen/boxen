require "json"
require "boxen/config"

config      = Boxen::Config.load
facts       = {}
factsdir    = "#{config.homedir}/config/facts"
dot_boxen   = "#{ENV['HOME']}/.boxen"
user_config = "#{dot_boxen}/config.json"

facts["github_login"]  = config.login
facts["github_email"]  = config.email
facts["github_name"]   = config.name
facts["github_token"]  = config.token

facts["boxen_home"]    = config.homedir
facts["boxen_srcdir"]  = config.srcdir
facts["boxen_repodir"] = config.repodir
facts["boxen_user"]    = config.user
facts["luser"]         = config.user # this is goin' away

def facter_interpolate(file)
  File.read(file).gsub(/\$\{(:*\w+)\}/) { |f| Facter.value(f.match(/\w+/)) }
end

def set_facts(h)
  h.each { |k, v| Facter.add(k) { setcode { v } } }
end

set_facts(facts)

Dir["#{config.homedir}/config/facts/*.json"].each do |file|
  set_facts JSON.parse facter_interpolate file
end

if File.directory?(dot_boxen) && File.file?(user_config)
  set_facts JSON.parse facter_interpolate user_config
end

if File.file?(dot_boxen)
  warn "DEPRECATION: ~/.boxen is deprecated and will be removed in 2.0; use ~/.boxen/config.json instead!"
  set_facts JSON.parse facter_interpolate dot_boxen
end
