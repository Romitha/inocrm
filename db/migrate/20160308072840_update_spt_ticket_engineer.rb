class UpdateSptTicketEngineer < ActiveRecord::Migration
  def change
    # create_table :spt_ticket_engineer, id: false do |t|
    #   t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
    #   t.column :ticket_id, "int(10) UNSIGNED NOT NULL"
    #   t.column :user_id, "int UNSIGNED NOT NULL"
    #   t.column :created_action_id, "INT UNSIGNED NULL"
    #   # t.index :ticket_id, name: "fk_spt_ticket_engineer_spt_ticket1"
    #   # t.index :user_id, name: "fk_spt_ticket_engineer_users1"
    #   # t.index :created_action_id, name: "fk_spt_ticket_engineer_spt_ticket_action1"
    #   t.timestamps
    # end

    # add_index :spt_ticket_engineer, :ticket_id
    # * give error *add_foreign_key(:spt_ticket_engineer, :spt_ticket, name: "fk_spt_ticket_engineer_spt_ticket1", column: :ticket_id)
    # add_index :spt_ticket_engineer, :user_id
    # * give error *add_foreign_key(:spt_ticket_engineer, :users, name: "fk_spt_ticket_engineer_users1", column: :user_id)
    # add_index :spt_ticket_engineer, :created_action_id
    # * give error *add_foreign_key(:spt_ticket_engineer, :spt_ticket_action, name: "fk_spt_ticket_engineer_spt_ticket_action1", column: :created_action_id)

    # add_column :spt_ticket_action, :action_engineer_id, "INT UNSIGNED NULL"
    # add_index :spt_ticket_action, :action_engineer_id
    # * give error *add_foreign_key :spt_ticket_action, :spt_ticket_engineer, name: "fk_spt_ticket_action_spt_ticket_engineer1", column: :action_engineer_id, on_delete: :restrict, on_update: :restrict
 
    # add_index :spt_ticket, :owner_engineer_id
    # * give error * add_foreign_key(:spt_ticket, :spt_ticket_engineer, name: "fk_spt_ticket_spt_ticket_engineer1", column: :owner_engineer_id)

    # add_column :spt_act_assign_ticket, :assign_to_engineer_id, "INT UNSIGNED NOT NULL"
    # add_index :spt_act_assign_ticket, :assign_to_engineer_id
    # *Cannot add or update a child row: a foreign key constraint fails* add_foreign_key(:spt_act_assign_ticket, :spt_ticket_engineer, name: "fk_spt_act_assign_ticket_spt_ticket_engineer1", column: :assign_to_engineer_id)

    # add_column :spt_ticket_fsr, :engineer_id, "INT UNSIGNED NOT NULL"
    # add_index :spt_ticket_fsr, :engineer_id
    # *e *add_foreign_key(:spt_ticket_fsr, :spt_ticket_engineer, name: "fk_spt_ticket_fsr_spt_ticket_engineer1", column: :engineer_id)

    # add_column :spt_ticket_estimation, :engineer_id, "INT UNSIGNED NOT NULL"
    # add_index :spt_ticket_estimation, :engineer_id
    # *e* add_foreign_key(:spt_ticket_estimation, :spt_ticket_engineer, name: "fk_spt_ticket_estimation_spt_ticket_engineer1", column: :engineer_id)

    # add_column :spt_ticket_spare_part, :engineer_id, "INT UNSIGNED NOT NULL"
    # add_index :spt_ticket_spare_part, :engineer_id
    # *e* add_foreign_key(:spt_ticket_spare_part, :spt_ticket_engineer, name: "fk_spt_ticket_spare_part_spt_ticket_engineer1", column: :engineer_id)

    # add_column :spt_ticket_on_loan_spare_part, :engineer_id, "INT UNSIGNED NOT NULL"
    # add_index :spt_ticket_on_loan_spare_part, :engineer_id
    # *e* add_foreign_key(:spt_ticket_on_loan_spare_part, :spt_ticket_engineer, name: "fk_spt_ticket_on_loan_spare_part_spt_ticket_engineer1", column: :engineer_id)

    # add_column :spt_ticket_customer_quotation, :engineer_id, "INT UNSIGNED NOT NULL"
    # add_index :spt_ticket_customer_quotation, :engineer_id
    # *e* add_foreign_key(:spt_ticket_customer_quotation, :spt_ticket_engineer, name: "fk_spt_ticket_customer_quotation_spt_ticket_engineer1", column: :engineer_id)

    # *e* remove_column :spt_act_ticket_close_approve, :job_belongs_to
    # Mysql2::Error: Error on rename of './inocrm_dev1/#sql-3c8_8d' to './inocrm_dev1/spt_act_ticket_close_approve' (errno: 150): ALTER TABLE `spt_act_ticket_close_approve` DROP `job_belongs_to`/home/ubuntu/.rvm/gems/ruby-2.2.0@rails_latest_4_2_1/gems/rack-mini-profiler-0.9.3/lib/patches/db/mysql2.rb:20:in `query'
    
    # add_column :spt_act_ticket_close_approve, :owner_engineer_id, "INT UNSIGNED NULL"
    # add_index :spt_act_ticket_close_approve, :owner_engineer_id
    # *e* add_foreign_key(:spt_act_ticket_close_approve, :spt_ticket_engineer, name: "fk_spt_act_ticket_close_approve_spt_ticket_engineer1", column: :owner_engineer_id)

  end
end
