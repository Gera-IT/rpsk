require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'rvm1/capistrano3'
require 'capistrano/rails'
require 'capistrano3/unicorn'
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
