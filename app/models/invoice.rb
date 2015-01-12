class Invoice < ActiveRecord::Base
	belongs_to :customer, class_name: "User"#, foreign_key: "customer_id"
end
