class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles # f the default name of the join table, based on lexical ordering, is not what you want, you can use the :join_table option to override the default. http://guides.rubyonrails.org/association_basics.html
  belongs_to :resource, :polymorphic => true
  
  scopify
end
