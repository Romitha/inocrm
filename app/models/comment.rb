class Comment < ActiveRecord::Base

	has_many :comment_visibilities
	has_many :watchers, class_name: "User", through: :comment_visibilities#, class_name: "User" have to analysis how support where("") as if condition

	belongs_to :agent, class_name: "User", foreign_key: "agent_id" #through where() user is ....

	belongs_to :ticket

	validates_presence_of [:subject, :content]

	has_many :dyna_columns, as: :resourceable

	[:history].each do |dyna_method|
    define_method(dyna_method) do
      dyna_columns.find_by_data_key(dyna_method).try(:data_value)
    end

    define_method("#{dyna_method}=") do |value|
      data = dyna_columns.find_or_initialize_by(data_key: dyna_method)
      data.data_value = (value.class==Fixnum ? value : value.strip)
    end
  end
end
