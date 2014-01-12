require "boxen/command/project"

class Boxen::Command::Project::Install < Boxen::Command::Project
  def self.detailed_help
    <<-EOS

    boxen project:install <project1> [<project2> ...]

        Install one or more Boxen-managed projects.

EOS
  end

  def self.help
    "Install one or more projects"
  end

  def run
    File.open("#{config.repodir}/.projects", "w+") do |f|
      f.truncate 0
      f.write projects
    end

    Boxen::Command.invoke 'run', config
  end

  def projects
    @args.join ','
  end
end

Boxen::Command.register :"project:install",  Boxen::Command::Project::Install
Boxen::Command.register :"projects:install", Boxen::Command::Project::Install
