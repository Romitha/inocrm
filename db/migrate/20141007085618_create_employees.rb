class CreateEmployees < ActiveRecord::Migration
  def change
    ## Employee User table
    create_table (:employees) do |t|
      # t.integer :user_id,       limit: 11,  null: false
      # t.integer :designation_id,    limit: 11
      t.string    :epf_no,        limit: 45
      # t.string  :learner_id,      limit: 50
      t.date      :date_joined
      # t.integer :termination_reason_id, limit: 11 
      t.date      :date_terminated
      t.string    :avatar
      t.integer   :terminated#,      limit: 1
      t.datetime  :deleted_at

      t.references :delete, polymorphic: true
      # t.integer   :deleted_id#,      limit: 11
      # t.string    :deleted_type

      t.timestamps
    end
  end
end
