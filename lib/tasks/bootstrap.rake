namespace :db do
  desc 'Drop, re-create database'
  task :bootstrap => [:drop, :create, :migrate]
end

