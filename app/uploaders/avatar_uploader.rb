class AvatarUploader < CarrierWave::Uploader::Base
  
  include Cloudinary::CarrierWave
  
  process :convert => 'jpg'
  process :tags => ['user_avatar']
  process :eager => true
  cloudinary_transformation :quality => 70
  
  def extension_white_list
      %w(jpg jpeg gif png)
    end
  
  if Rails.env.production?
    def public_id
      "production/" + "#{model.id}_avatar"
    end
  elsif Rails.env.staging?
    def public_id
      "staging/" + "#{model.id}_avatar"
    end
  else
    def public_id
      "development/" + "#{model.id}_avatar"
    end
  end

end