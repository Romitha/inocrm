class MasterIndustryTypes < ActiveRecord::Migration
  def change
  	create_table (:mst_industry_types) do |t|
		t.string 		:name,      limit: 200
		t.string 		:code,      limit: 3
		t.boolean 		:deleted
	end
  end
end
