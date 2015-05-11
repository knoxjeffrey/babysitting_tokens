Fabricator(:user) do
  email { Faker::Internet.email }
  password { Faker::Internet.password(6) }
  full_name { Faker::Name.name } 
end

Fabricator(:user_avatar_upload, from: :user) do
  avatar { File.open("#{Rails.root}/spec/support/uploads/user_avatar.jpg") }
end
