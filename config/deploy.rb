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
$SERVER_WEB_LOCAL_1  = '192.168.11.21'
$SERVER_WEB_LOCAL_2  = '192.168.11.20'

$SERVER_WEB_LIVE_1  = '210.14.69.149'
$SERVER_WEB_LIVE_2  = '210.14.69.150'
$SERVER_WEB_LIVE_3  = '211.144.78.122'
#$SERVER_DB_LIVE  = '210.14.69.150'

$SERVER_SCM_LOCAL = '192.168.11.21'
$SERVER_SCM_LIVE = '210.14.69.149'
#-------------------------------------------

default_run_options[:pty] = true

puts "target is #{target}"
puts "app is #{app}"

case target
  when 'local'
    puts "branch is #{branch}"
  
    role :app,        $SERVER_WEB_LOCAL_1
    #role :static,     $SERVER_WEB_LOCAL_1
    role :thin,       $SERVER_WEB_LOCAL_1
    role :passenger,  $SERVER_WEB_LOCAL_1
    role :sphinx,     $SERVER_WEB_LOCAL_1
    
    set :repository, "git@192.168.11.21:/data/git/nbd.git"
    set :branch, branch

  when 'live'
    answer = Capistrano::CLI.ui.ask "Are you sure to deploy to '#{target.upcase}? (yes/no) "
    exit(0) if answer != 'yes'
  
    role :app,        $SERVER_WEB_LIVE_1, $SERVER_WEB_LIVE_2
    #role :static,     $SERVER_WEB_LIVE_3
    role :thin,       $SERVER_WEB_LIVE_1, $SERVER_WEB_LIVE_2
    role :passenger,  $SERVER_WEB_LIVE_1
    role :sphinx,     $SERVER_WEB_LIVE_1
    
    set :repository, "git@210.14.69.150:/data/git/nbd.git"
    set :branch, "master"
end

set :application, "#{app}"
set :scm_verbose, true
set :scm, :git
set :user, "dog"
set :use_sudo, false
set :keep_releases, 5
set :deploy_to, "/var/www/#{application}"
set :rvm_path, "/usr/local/bin/nbd_rvm"


  task :nbd_bundle, :roles => :app do
    run "cd #{deploy_to}/current && #{rvm_path} bundle install"
  end
namespace :deploy do

  task :start, :roles => :app do
  end
  
  task :stop, :roles => :app do
  end
  
  before "deploy:restart", "nbd_bundle"

  task :restart, :roles => :app, :except => { :no_release => true } do
    restart_passenger if roles[:passenger].present?
    restart_thin if roles[:thin].present?
  end

  
  after 'deploy:symlink', 'deploy:symlink_for_target'
  task :symlink_for_target, :roles => [:app] do
    run "#{rvm_path} ruby /var/www/nbd/current/shared/run_deploy.rb '#{deploy_to}' '#{target}' "
  end
  
  after 'nbd_bundle', 'deploy:generate_sphinx_conf'
  task :generate_sphinx_conf, :roles => :sphinx do
    run "cd #{deploy_to}/current && #{rvm_path} rake ts:conf RAILS_ENV=production"
  end
  
  task :restart_thin, :roles => [:thin] do
    run "#{rvm_path} thin -C /etc/thin/#{application}.yml -O restart"
  end
  
  task :restart_passenger, :roles => [:passenger] do
    run "touch #{File.join("#{deploy_to}/current",'tmp','restart.txt')}"
  end
  
  
 
end
