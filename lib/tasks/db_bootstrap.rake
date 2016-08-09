desc "bootstraping database"
namespace :db do
  task :bootstrap => [:drop, :create, :migrate, :seed]
end

task clear_dalli_cache: :environment do
  Rails.cache.clear
end

# task flush_logfiles: :environment do
#   logfile = File.open File.join(Rails.root, "log", "production.log")
#   if logfile.size >= 10.megabytes
#     File.delete logfile
#     new_logfile = File.new File.join(Rails.root, "log", "production.log"), "w"
#     new_logfile.chmod 0777
#   end
# end

task :flush_logfile do
  options = {}
  opts = OptionParser.new

  opts.banner = "Usage: rake add [options]"
  opts.on("-p NAME", "--path NAME", String, "sample") { |o| options[:path] = o }
  opts.on("-s NAME", "--stage NAME", String, "sample") { |o| options[:stage] = o }

  args = opts.order!(ARGV) {}
  opts.parse!(args)

  path = options[:path]
  stage = options[:stage]

  logfile = File.open File.join(path, "log", "#{stage}.log")
  if logfile.size >= 10.megabytes
    File.delete logfile
    new_logfile = File.new File.join(path, "log", "#{stage}.log"), "w"
    new_logfile.chmod 0777
  end

  exit

end