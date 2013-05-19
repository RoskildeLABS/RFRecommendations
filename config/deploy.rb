require "bundler/capistrano"
load 'deploy/assets'

# SERVER
set :application, "rf-recommendations.brnbw.com"
set :domain,      "#{application}"
set :user,        "mikker"
set :use_sudo,    false
set :deploy_to,   "/var/www/apps/#{application}"

# Roles
role :web,                domain
role :app,                domain
role :db,                 domain, :primary => true

# GIT
set :scm, :git
set :repository, "git@github.com:mikker/rf-recommendation-engine.git"
set :branch, 'master'
set :deploy_via, :remote_cache
set :keep_releases, 3

# SSH
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
# ssh_options[:paranoid] = true # comment out if it gives you trouble. newest net/ssh needs this set.

# RBENV
set :default_environment, { 'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }
set :bundle_flags, "--deployment --quiet --binstubs"

# Custom Tasks
namespace :deploy do
  task(:start) {}
  task(:stop) {}

  desc "Restart Application"
  task :restart, :roles => :web, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :setup_shared do
    run "mkdir #{shared_path}/config"
    run "mkdir #{shared_path}/db"
    config_files.each do |example, file|
      put File.read(example), "#{shared_path}/#{file}"
    end
    puts "Now edit the config files and fill assets folder in #{shared_path}."
  end

  task :symlink_extras do
    config_files.each do |example, file|
      run "ln -nfs #{shared_path}/#{file} #{release_path}/#{file}"
    end
  end
end

def config_files
  @config_files ||= Dir["config/*.example"].inject({}) do |hsh, file|
    hsh.merge(file => file.gsub(/\.example$/, ""))
  end
end

after 'deploy:setup', 'deploy:setup_shared'
before 'deploy:assets:precompile', 'deploy:symlink_extras'
after 'deploy:create_symlink', 'deploy:cleanup'

