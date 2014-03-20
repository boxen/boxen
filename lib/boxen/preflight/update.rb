require "boxen/preflight"

class Boxen::Preflight::Update < Boxen::Preflight
  def ok?
    if config.offline?
      warn "Skipping update because we're offline."

    else
      if should_update?
        info "Updating boxen..."
        fetch

        if !on_branch?
          warn "Boxen not on a branch (ref: #{ref}), cannot update!"

        elsif !on_master_branch?
          local_branch = current_branch.rpartition("/").last
          warn "Boxen on a non-master branch '#{local_branch}', cannot update!"

        elsif !fast_forwardable?
          warn "Boxen has unpushed changes, cannot update!"

        elsif !clean_tree?
          warn "Boxen repo has untracked or uncommitted changes, cannot update!"

        elsif !upstream_changes?
          info "Boxen is up-to-date with origin/master"

        elsif update_boxen_checkout
          info "Successfully updated to #{ref}"
          rerun_boxen

        else
          warn "Failed to auto-update!"
          false
        end
      end
    end

    true
  end

  def run
    abort "Auto-update of Boxen FAILED, please fix manually."
  end

  private

  def ref
    %x(git log -1 --pretty=format:%h)
  end

  def fetch
    "git fetch --quiet origin"
  end

  def reset_hard
    "git reset --hard origin/master 2>&1 >/dev/null"
  end

  def clean
    "git clean -qdf"
  end

  def update_boxen_checkout
    %x(#{reset} && #{clean})
    $? == 0
  end

  def on_branch?
    !current_branch.empty?
  end

  def on_master_branch?
    current_branch == "refs/heads/master"
  end

  def clean_tree?
    %x(git status --porcelain).chomp.empty?
  end

  def upstream_changes?
    %x(git rev-list --count HEAD..origin/master).chomp != "0"
  end

  def should_update?
    ARGV.none? { |arg| arg == "--no-pull" }
  end

  def fast_forwardable?
    %x(git rev-list --count origin/master..master).chomp == "0"
  end

  def current_branch
    @current_branch ||= %x(git symbolic-ref HEAD).chomp
  end

  def rerun_boxen
    command = "#{$0} #{ARGV.join ' '} --no-pull"
    debug "Re-running boxen:"
    debug "  #{command.inspect}"
    exec command
  end
end
