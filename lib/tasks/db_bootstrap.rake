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
    # new_logfile.chmod 0664 have to symlink
  end

  exit

end

namespace :tire do
  task deep_import: :environment do
    pclass = eval(ENV['PCLASS'].to_s)
    klass = eval(ENV['CLASS'].to_s)
    total = klass.count rescue nil
    params = eval(ENV['PARAMS'].to_s) || {}

    if ENV['INDEX']
      index = Tire::Index.new(ENV['INDEX'])
      params[:index] = index.name
    else
      index = klass.tire.index
    end

    Tire::Tasks::Import.add_pagination_to_klass(klass)
    Tire::Tasks::Import.progress_bar(klass, total) if total

    Tire::Tasks::Import.delete_index(index) if ENV['FORCE']
    Tire::Tasks::Import.create_index(index, klass)

    Tire::Tasks::Import.import_model(index, klass, params)
    puts '[IMPORT] Done.'

  end

  task index_all_model: :environment do
    [['Grn'], ['GrnItem', 'Grn'], ['InventoryProduct', 'Inventory'], ['InventorySerialItem', 'Inventory'], ['Product'], ['Ticket'], ['InventoryPrn', 'Inventory'], ['InventoryPo', 'Inventory'], ["Gin"], ['Organization']].each do |models|
      system "rake environment tire:deep_import CLASS=#{models.first} PCLASS=#{models.last} FORCE=true"
    end
  end
end

task upload_printer_template: :environment do
  Ticket
  ["fsr", "bundle_hp", "invoice", "quotation", "receipt", "ticket", "ticket_complete", "ticket_sticker"].each do |print|
    file = File.open File.join(Rails.root, "printer_templates", "print_#{print}.xml"), "rb"
    PrintTemplate.first.update_attribute print.to_sym, file.read
  end
end