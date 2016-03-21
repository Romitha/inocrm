desc "bootstraping database"
namespace :db do
  task :bootstrap => [:drop, :create, :migrate, :seed]
end

task clear_dalli_cache: :environment do
  Rails.cache.clear
end