class CreateOrganizationContactExtras < ActiveRecord::Migration
  def change
    create_table :organization_contact_extras do |t|
    	t.integer	:organization_id,	limit:11
    	t.integer	:type_id,			limit:11
    	t.string	:value,				limit:200
    	t.boolean	:deleted
    end
  end
end
