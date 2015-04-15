class UserGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  #delegate :group_name, to: :group
  #delegate :tokens, to: :user
end