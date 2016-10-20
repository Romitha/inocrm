class Rpermission < ActiveRecord::Base
  has_and_belongs_to_many :roles

  belongs_to :subject_class
  belongs_to :subject_attribute
  belongs_to :subject_base

end

class SubjectClass < ActiveRecord::Base
  has_many :rpermissions
end

class SubjectAttribute < ActiveRecord::Base
  has_many :rpermissions
  
end

class SubjectAction < ActiveRecord::Base
  has_many :rpermissions
  belongs_to :subject_action_alias, class_name: "SubjectAction"
  has_many :subject_alias_actions, class_name: "SubjectAction", foreign_key: :subject_action_alias_id
  
end

class SubjectBase < ActiveRecord::Base
  has_many :subject_classes
end