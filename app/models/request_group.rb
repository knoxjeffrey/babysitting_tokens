class RequestGroup < ActiveRecord::Base
  belongs_to :request
  belongs_to :group
end