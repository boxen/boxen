require "boxen/command"
#require "boxen/service"

class Boxen::Command::Project < Boxen::Command
  def self.detailed_help
    <<-EOS

    boxen project

        Display all projects Boxen knows about.

    boxen project:install <project1> [<project2> ...]

        Install a Boxen-managed project.

EOS
  end

  def self.help
    "Show and install Boxen-managed projects"
  end

  def run
    @args = [] # we don't care about args here

    puts "Boxen knows about the following projects:"
    puts

    projects.each do |project|
      puts "    #{project.name}"
    end

    puts
    puts "You can install any of them by running \"boxen project:install <project>\""
    puts

    Boxen::CommandStatus.new(0)
  end

  def projects
    @projects ||= @config.projects
  end
end

require "boxen/command/project/install"

Boxen::Command.register :project,  Boxen::Command::Project
Boxen::Command.register :projects, Boxen::Command::Project
