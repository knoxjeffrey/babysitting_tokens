module ClearIdentifier
  extend ActiveSupport::Concern
  
  def clear_identifier_column
    self.update_column(:identifier, nil)
  end
  
end