namespace :rsync_scm do
  def rsync_base_options
    %w(
    --checksum
    --times
    --hard-links
    --links
    --perms
    --compress
    --recursive
    --exclude=/.gitignore
    --exclude=.keep
    --files-from=-
    --from0)
  end

  def strategy
    @strategy ||= Capistrano::RsyncScm.new(self, fetch(:rsync_scm_strategy, Capistrano::RsyncScm::GitStrategy))
  end

  task :check do
    exit 1 unless strategy.check
  end

  desc 'Copy repo to releases'
  task :create_release do
    strategy.with_clone do |source|
      on release_roles :all do |release_role|
        last_release = capture(:ls, '-xr', releases_path).split.first
        last_release_path = releases_path.join(last_release) if last_release

        rsync_options = rsync_base_options
        rsync_options << "--link-dest=#{last_release_path}" if last_release_path

        target = if release_role.user.nil? || release_role.user.empty?
          "#{release_role.user}@#{release_role.hostname}:#{release_path}"
        else
          "#{release_role.hostname}:#{release_path}"
        end

        command = "cd #{source} && git ls-files -z | rsync #{rsync_options.join(' ')} '.' #{target}"

        run_locally do
          execute command
        end
      end
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    set :current_revision, strategy.fetch_revision
  end
end
