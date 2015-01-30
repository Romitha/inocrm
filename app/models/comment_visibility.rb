class CommentVisibility < ActiveRecord::Base
  belongs_to :comment
  belongs_to :watcher
end
