class CreateMasterDesignations < ActiveRecord::Migration
  def change
    create_table :mst_designations do |t|
		t.string	:name,	limit:200
		t.boolean	:deleted
    end
  end
end
