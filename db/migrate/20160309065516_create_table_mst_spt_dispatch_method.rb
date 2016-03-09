class CreateTableMstSptDispatchMethod < ActiveRecord::Migration
  def change
    create_table :mst_spt_dispatch_method, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.column :name, "VARCHAR(250) NOT NULL"
    end

    add_column :spt_act_customer_feedback, :dispatch_method_id, "INT UNSIGNED NULL"
    add_index :spt_act_customer_feedback, :dispatch_method_id
    add_foreign_key :spt_act_customer_feedback, :mst_spt_dispatch_method, name: :fk_spt_act_customer_feedback_mst_spt_dispatch_method1, column: :dispatch_method_id

    create_table :spt_act_quotation, id: false do |t|
      t.column :ticket_action_id, "INT UNSIGNED NOT NULL, PRIMARY KEY (ticket_action_id)"
      t.column :customer_quotation_id, "INT UNSIGNED NOT NULL"
      t.index :ticket_action_id, name: "fk_spt_act_quotation_spt_ticket_action1_idx"
      t.index :customer_quotation_id, name: "fk_spt_act_quotation_spt_ticket_customer_quotation1_idx"
    end

    add_foreign_key :spt_act_quotation, :spt_ticket_action, name: :fk_spt_act_quotation_spt_ticket_action1, column: :ticket_action_id
    add_foreign_key :spt_act_quotation, :spt_ticket_customer_quotation, name: :fk_spt_act_quotation_spt_ticket_customer_quotation1, column: :customer_quotation_id
    
  end
end
