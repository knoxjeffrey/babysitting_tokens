class UserGroup < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :group
  
  def update_tokens(new_token_amount)
    self.update_attributes(tokens: new_token_amount)
  end
end