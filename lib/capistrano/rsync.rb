load File.expand_path("../tasks/rsync.rake", __FILE__)

require 'capistrano/scm'
require 'tmpdir'


class Capistrano::Rsync < Capistrano::SCM
  VERSION = "0.0.1"

  # The Capistrano default strategy for git. You should want to use this.
  module GitStrategy
    def check
      File.exists?(File.join('.git', 'refs', 'heads', fetch(:branch).to_s))
    end

    def with_clone(&block)
      tmpdir = Dir.mktmpdir('capistrano-rsync-')
      begin
        run_locally do
          execute :git, 'clone', '--quiet', fetch(:repo_url), tmpdir
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