Fabricator(:group) do
  group_name { Faker::Company.name }
  location { Faker::Address.city }
end