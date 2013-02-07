module Boxen

  # A project managed by Boxen.

  class Project

    # The directory where this project's repo should live.

    attr_reader :dir

    # The name of this project.

    attr_reader :name

    def initialize(dir)
      @dir  = dir
      @name = File.basename @dir
    end
  end
end
