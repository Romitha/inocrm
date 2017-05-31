class Rpermission < ActiveRecord::Base
  has_and_belongs_to_many :roles # ok

  belongs_to :subject_class # ok
  # belongs_to :subject_attribute
  # belongs_to :subject_base
  has_many :subject_attributes # ok
  has_many :subject_actions # ok

end

class SubjectClass < ActiveRecord::Base
  has_many :rpermissions
end

class SubjectAttribute < ActiveRecord::Base
  # has_many :rpermissions
  belongs_to :rpermission # ok
  
end

class SubjectAction < ActiveRecord::Base
  # has_many :rpermissions
  belongs_to :rpermission # ok
  # belongs_to :subject_action_alias, class_name: "SubjectAction"
  # has_many :subject_alias_actions, class_name: "SubjectAction", foreign_key: :subject_action_alias_id
  
end

class SubjectBase < ActiveRecord::Base
  has_many :subject_classes
end