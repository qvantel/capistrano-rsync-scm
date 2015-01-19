load File.expand_path("../tasks/rsync_scm.rake", __FILE__)

require 'capistrano/scm'
require 'tmpdir'


class Capistrano::RsyncScm < Capistrano::SCM
  VERSION = "0.0.1"

  # The Capistrano default strategy for git. You should want to use this.
  module GitStrategy
    def check
      File.exists?(File.join('.git', 'refs', 'heads', fetch(:branch).to_s))
    end

    def with_clone(&block)
      tmpdir = Dir.mktmpdir('capistrano-rsync-scm-')
      begin
        run_locally do
          execute :git, 'clone', '--quiet', "--branch=#{fetch(:branch)}", fetch(:repo_url), tmpdir
        end
        block.call(tmpdir)
      ensure
        FileUtils.remove_entry(tmpdir)
      end
    end

    def fetch_revision
      `git rev-parse --short #{fetch(:branch)}`
    end
  end
end
