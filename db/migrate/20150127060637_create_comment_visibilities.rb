class CreateCommentVisibilities < ActiveRecord::Migration
  def change
    create_table :comment_visibilities do |t|
      t.references :comment, index: true
      t.references :watcher, index: true
      t.string :visibility

      t.timestamps
    end
  end
end
