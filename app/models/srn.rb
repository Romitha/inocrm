class Srn < ActiveRecord::Base
  self.table_name = "inv_srn"

  belongs_to :store, class_name: "Organization"
  belongs_to :requested_location, class_name: "Organization"

  has_many :srn_items
end

class SrnItem < ActiveRecord::Base
  self.table_name = "inv_srn_item"

  belongs_to :srn
  belongs_to :product
end