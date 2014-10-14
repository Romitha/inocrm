class CreateMasterTerminationReasons < ActiveRecord::Migration
  def change
    create_table (:mst_termination_reasons) do |t|
    	t.string	:name,	limit:200
    	t.string	:code,	limit:3
    	t.boolean	:deleted
    end
  end
end
