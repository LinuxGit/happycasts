require "bundler/capistrano"
set :application, "happycasts"
set :repository,  "git://github.com/happypeter/happycasts.git"

set :scm, :git

set :user, "peter"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :branch, "master"

default_run_options[:pty] = true
server "happycasts.net", :web, :app, :db, :primary => true

after "deploy:restart", "deploy:cleanup"

#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "things I need to do after deploy:setup"
  task :setup_config, :roles => :app do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit #{shared_path}/config/database.yml . And create db: happycasts_production"
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"
end
