class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :ticket_type
      t.string :status
      t.string :subject
      t.string :priority
      t.text :description
      t.string :initiated_through
      t.boolean :deleted

      [:organization, :department, :customer].each do |reference|
        t.references reference, index: true
      end

      t.timestamps
    end
  end
end
