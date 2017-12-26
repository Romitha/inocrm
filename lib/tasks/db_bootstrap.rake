require 'backburner/tasks'

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
    [['Grn'], ['GrnItem', 'Grn'], ['GrnBatch', 'Grn'], ['InventoryProduct', 'Inventory'], ['InventorySerialItem', 'Inventory'], ['InventoryBatch', 'Inventory'], ['Product'], ['Ticket', 'ContactNumber'], ['InventoryPrn', 'Inventory'], ['InventoryPo', 'Inventory'], ["Gin"], ['Organization'], ['SoPo', 'TicketSparePart'], [ "Srr", "Srr" ], [ "Srn", "Srn" ], [ "SrnItem", "Srn" ], ["ContactPerson1", "User"], ["ContactPerson2", "User"], ["ReportPerson", "User"], ["Customer", "User"], ['TicketContract', 'Ticket'], ['ContractProduct', 'Ticket']].each do |models|
      system "rake environment tire:deep_import CLASS=#{models.first} PCLASS=#{models.last} FORCE=true"
    end
  end
end

task upload_printer_template: :environment do
  Ticket
  WorkflowMapping
  ["fsr", "bundle_hp", "invoice", "quotation", "receipt", "ticket", "ticket_complete", "ticket_sticker"].each do |print|
    file = File.open File.join(Rails.root, "printer_templates", "print_#{print}.xml"), "rb"
    PrintTemplate.first.update_attribute print.to_sym, file.read
  end

  ['ASSIGN_JOB', 'COMPLETE_JOB', 'INVOICE_COMPLETED', 'NEW_TICKET', 'PART_ISSUED'].each do |f|
    file = File.open File.join(Rails.root, "printer_templates", "#{f}.txt"), "rb"
    EmailTemplate.find_by_code(f).update_attribute :body, file.read
  end
end

task seed_roles_permissions: :environment do
  Rpermission

  # SubjectAction.delete_all
  # Rpermission.delete_all
  # SubjectAttribute.delete_all

  permission_file = File.join Rails.root, "config", "permissions_list.yaml"
  permissions = YAML.load File.open(permission_file)

  permissions.each do |key, value|
    s_class = SubjectClass.find_or_create_by(name: key)

    value.each do |s_key, s_value|
      rpermission = s_class.rpermissions.find_or_create_by name: s_key

      if s_value and s_value["actions"].present?
        # rpermission.subject_actions.create s_value["actions"].map { |e| { name: e } }
        s_value["actions"].to_a.each do |action|
          rpermission.subject_actions.find_or_create_by name: action
        end

      end

      if s_value and s_value["attributes"].present?
        # rpermission.subject_attributes.create s_value["attributes"]
        s_value["attributes"].to_a.each do |attribute|
          rpermission.subject_attributes.find_or_create_by name: attribute["name"], value: attribute["value"]
        end

      end

      if s_value and s_value["system_module"].present?
        # rpermission.subject_attributes.create s_value["attributes"]
        unless rpermission.rpermission_module.present?
          rm = RpermissionModule.find_or_create_by name: s_value["system_module"]["name"]
          rpermission.rpermission_module_id = rm.id
          rpermission.save!

        end

      end
    end

  end

end