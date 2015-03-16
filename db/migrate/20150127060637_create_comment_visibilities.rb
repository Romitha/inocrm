class CreateCommentVisibilities < ActiveRecord::Migration
  def change
    create_table :comment_visibilities, id: false do |t|
      t.column :id, "INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)"
      t.references :comment, index: true
      t.references :watcher, index: true
      t.string :visibility

      t.timestamps
    end
  end
end
