desc "bootstraping database"
namespace :db do
  task :bootstrap => [:drop, :create, :migrate, :seed]
end