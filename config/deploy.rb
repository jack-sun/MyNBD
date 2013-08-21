require 'rubygems'
require 'action_mailer'
require 'json'
#require 'thinking_sphinx/deploy/capistrano'
#require "bundler/capistrano"

# USAGE:
#   
#  [deploy]
#
#   cap  deploy -S app='nbd' -S target='live'
#   cap  deploy -S app='nbd' -S -S target='local'
#   cap  deploy -S app='nbd_preview' -S target='live'
#
#  [cleanup]
#
#   cap -deploy:cleanup -S app='nbd_preview' -S target='live'
# --------------- Servers --------------- 
$SERVER_LOCAL_WEB  = '192.168.11.21'
$SERVER_BS_LOG = '101.226.199.30' # ip for dian xin.
$SERVER_QUANZHOU_WEB = '61.154.116.158'

$SERVER_SCM_LOCAL = '192.168.11.21'
$SERVER_SCM_LIVE = $SERVER_BS_LOG
#-------------------------------------------

default_run_options[:pty] = true

puts "target is #{target}"
puts "app is #{app}"

case target
  when 'local'
    puts "branch is #{branch}"
  
    role :app,        $SERVER_LOCAL_WEB
    role :thin,       $SERVER_LOCAL_WEB
    role :passenger,  $SERVER_LOCAL_WEB
    role :sphinx,     $SERVER_LOCAL_WEB
    
    set :repository, "git@#{$SERVER_SCM_LOCAL}:/data/git/nbd.git"
    set :branch, branch

  when 'live' #baoshan shard
    answer = Capistrano::CLI.ui.ask "Are you sure to deploy to '#{target.upcase}? (yes/no) "
    exit(0) if answer != 'yes'
  
    set :gateway, $SERVER_BS_LOG
    role :app, "bs-app1"
    role :passenger, "bs-app1"
    role :sphinx, "bs-app1"
    
    set :repository, "git@#{$SERVER_SCM_LIVE}:/data/git/nbd.git"
    set :branch, "master"

  when 'quanzhou'
    answer = Capistrano::CLI.ui.ask "Are you sure to deploy to '#{target.upcase}? (yes/no) "
    exit(0) if answer != 'yes'
    puts "branch is #{branch}"
  
    role :app,        $SERVER_QUANZHOU_WEB
    role :passenger,  $SERVER_QUANZHOU_WEB
    role :sphinx,     $SERVER_QUANZHOU_WEB
    
    set :repository, "git@#{$SERVER_SCM_LIVE}:/data/git/nbd.git"
    set :branch, branch
end

set :application, "#{app}"
set :scm_verbose, true
set :scm, :git
set :user, "dog"
set :user_sudo, false
set :keep_releases, 10
set :deploy_to, "/var/www/#{application}"
set :rvm_path, "/usr/local/bin/nbd_rvm"

namespace :deploy do
  task :start, :roles => :app do

  end

  task :stop, :roles => :app do

  end

  task :restart, :roles => :app, :except => {:no_release => true} do
    restart_passenger if roles[:passenger].present?
    restart_thin if roles[:thin].present?
  end

  task :restart_passenger, :roles => :passenger do
     run "touch #{File.join("#{deploy_to}/current",'tmp','restart.txt')}"
  end

  task :restart_thin, :roles => :thin do
    run "#{rvm_path} thin -C /etc/thin/#{application}.yml -O restart"
  end
  
  before "deploy:restart", 'deploy:push_static_resources'
  task :push_static_resources, :roles => :app do
    run "/home/dog/bin/push_to_web.sh"
  end

  before "deploy:restart", "deploy:nbd_bundle"
  task :nbd_bundle, :roles => :app do
    run "cd #{deploy_to}/current && #{rvm_path} bundle install"
  end

  after 'deploy:nbd_bundle', 'deploy:generate_sphinx_conf'
  task :generate_sphinx_conf, :roles => :sphinx do
    run "cd #{deploy_to}/current && #{rvm_path} bundle exec rake ts:conf RAILS_ENV=production"
  end

  after 'deploy:symlink', 'deploy:symlink_for_target'
  task :symlink_for_target, :roles => :app do
    run "#{rvm_path} ruby /var/www/nbd/current/shared/run_deploy.rb '#{deploy_to}' '#{target}' "
  end



end
