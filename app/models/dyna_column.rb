class DynaColumn < ActiveRecord::Base
  belongs_to :resourceable, polymorphic: true
end
