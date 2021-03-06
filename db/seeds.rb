8# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(email: 'knoxjeffrey@outlook.com', password: 'password', full_name: "Jeff Knox")
User.create(email: 'knoxjeffrey@hotmail.com', password: 'password', full_name: "Hazel Knox")
User.create(email: 'lisamckibben@hotmail.com', password: 'password', full_name: "Lisa McKibben")
User.create(email: 'rachelmacauley@hotmail.com', password: 'password', full_name: "Rachel Macauley")
User.create(email: 'peterlord@hotmail.com', password: 'password', full_name: "Peter Lord")

Group.create(group_name: 'Woodfield', location: 'Edinburgh', admin_id: 1)
Group.create(group_name: 'Colinton', location: 'Edinburgh', admin_id: 1)
Group.create(group_name: 'Waringstown', location: 'Northern Ireland', admin_id: 3)

UserGroup.create(user_id: 1, group_id: 1, tokens: 11)
UserGroup.create(user_id: 1, group_id: 2, tokens: 14)
UserGroup.create(user_id: 1, group_id: 3)
UserGroup.create(user_id: 2, group_id: 1, tokens: 23)
UserGroup.create(user_id: 2, group_id: 2, tokens: 11)
UserGroup.create(user_id: 3, group_id: 1, tokens: 23)
UserGroup.create(user_id: 3, group_id: 2, tokens: 26)
UserGroup.create(user_id: 4, group_id: 1, tokens: 17)

Request.create(user_id: 1, start: DateTime.new(2018, 03, 17, 19, 00, 0), finish: DateTime.new(2018, 03, 17, 22, 00, 0), status: 'accepted', babysitter_id: 2, group_ids: [1,2,3], group_id: 1)
Request.create(user_id: 1, start: DateTime.new(2020, 03, 17, 19, 00, 0), finish: DateTime.new(2020, 03, 17, 22, 00, 0), status: 'accepted', babysitter_id: 2, group_ids: [1,2], group_id: 1)
Request.create(user_id: 1, start: DateTime.new(2018, 04, 02, 18, 00, 0), finish: DateTime.new(2018, 04, 02, 23, 00, 0), status: 'waiting', group_ids: [1])
Request.create(user_id: 2, start: DateTime.new(2018, 03, 21, 19, 00, 0), finish: DateTime.new(2018, 03, 21, 22, 00, 0), status: 'waiting', group_ids: [1,2])
Request.create(user_id: 3, start: DateTime.new(2018, 03, 23, 19, 00, 0), finish: DateTime.new(2018, 03, 23, 22, 00, 0), status: 'waiting', group_ids: [1])
Request.create(user_id: 4, start: DateTime.new(2018, 03, 25, 19, 00, 0), finish: DateTime.new(2018, 03, 25, 22, 00, 0), status: 'waiting', group_ids: [1])
Request.create(user_id: 1, start: DateTime.new(2015, 04, 19, 17, 00, 0), finish: DateTime.new(2015, 04, 19, 23, 00, 0), status: 'completed', babysitter_id: 2, group_ids: [1,2,3], group_id: 2)
Request.create(user_id: 2, start: DateTime.new(2015, 04, 20, 18, 00, 0), finish: DateTime.new(2015, 04, 20, 22, 00, 0), status: 'completed', babysitter_id: 3, group_ids: [1], group_id: 1)
Request.create(user_id: 2, start: DateTime.new(2018, 04, 20, 18, 00, 0), finish: DateTime.new(2018, 04, 20, 22, 00, 0), status: 'accepted', babysitter_id: 3, group_ids: [2], group_id: 2)