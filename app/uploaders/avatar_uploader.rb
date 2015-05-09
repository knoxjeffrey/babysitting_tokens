class AvatarUploader < CarrierWave::Uploader::Base
  
  include Cloudinary::CarrierWave

  process :tags => ['user_avatar']

  version :standard do
    process :eager => true

    cloudinary_transformation :quality => 70
  end

  version :thumbnail do
    eager
    resize_to_fit(50, 50)
  end

end