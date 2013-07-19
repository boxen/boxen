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

Dir["#{config.homedir}/config/facts/*.json"].each do |file|
  facts.merge! JSON.parse File.read file
end

if File.directory?(dot_boxen) && File.file?(user_config)
  facts.merge! JSON.parse(File.read(user_config))
end

if File.file?(dot_boxen)
  warn "DEPRECATION: ~/.boxen is deprecated and will be removed in 2.0; use ~/.boxen/config.json instead!"
  facts.merge! JSON.parse(File.read(dot_boxen))
end

facts.each { |k, v| Facter.add(k) { setcode { v } } }
