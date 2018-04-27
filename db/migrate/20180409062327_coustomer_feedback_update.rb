class CoustomerFeedbackUpdate < ActiveRecord::Migration
  def change
	add_column :spt_act_customer_feedback, :re_open_reason, "TEXT NULL"
  end
end
