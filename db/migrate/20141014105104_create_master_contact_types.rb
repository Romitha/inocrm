class CreateMasterContactTypes < ActiveRecord::Migration
  def change
    create_table :mst_contact_types do |t|
    	t.string	:name,	limit:200
    	t.string	:code,	limit:3
    	t.string	:type,	limit:11
    	t.boolean	:deleted
    end
  end
end
