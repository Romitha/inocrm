class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles # f the default name of the join table, based on lexical ordering, is not what you want, you can use the :join_table option to override the default. http://guides.rubyonrails.org/association_basics.html
  belongs_to :resource, :polymorphic => true
  
  has_and_belongs_to_many :rpermissions
  # scopify

  validates :name, presence: true, uniqueness: true

  has_many :module_roles, foreign_key: :role_id
  has_many :bpm_module_roles, through: :module_roles

  def cached_rpermissions
    Rails.cache.fetch([id.try(:to_i), :rpermissions]){rpermissions}
  end

  def flush_cache
    Rails.cache.delete([id.try(:to_i), :rpermissions])
  end

  after_save do |role|
    role.flush_cache
  end

end

class ModuleRole < ActiveRecord::Base
  self.table_name = "role_bpm_role"

  belongs_to :role, foreign_key: :role_id
  belongs_to :bpm_module_role, foreign_key: :bpm_role_id
end

class BpmModuleRole < ActiveRecord::Base
  self.table_name = "mst_bpm_role"

  belongs_to :bpm_module, foreign_key: :module_id

  has_many :module_roles, foreign_key: :bpm_role_id
  has_many :roles, through: :module_roles
  has_many :workflow_mappings, foreign_key: :bpm_role_id

end

class BpmModule < ActiveRecord::Base
  self.table_name = "mst_module"

  has_many :bpm_module_roles, foreign_key: :module_id
  has_many :srns, foreign_key: :requested_module_id
end