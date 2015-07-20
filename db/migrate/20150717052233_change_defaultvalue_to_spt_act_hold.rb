class ChangeDefaultvalueToSptActHold < ActiveRecord::Migration
  def change
    change_column_default :spt_act_hold, :un_hold_action_id, nil
  end
end
