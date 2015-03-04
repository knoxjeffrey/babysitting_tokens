# This file should contain all the record creation needed to seed the database with its default values.
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

Request.create(user_id: 1, start: DateTime.new(2015, 03, 17, 19, 00, 0), finish: DateTime.new(2015, 03, 17, 22, 00, 0), status: 'accepted')
Request.create(user_id: 1, start: DateTime.new(2015, 04, 02, 18, 00, 0), finish: DateTime.new(2015, 04, 02, 23, 00, 0), status: 'waiting')
Request.create(user_id: 2, start: DateTime.new(2015, 03, 21, 19, 00, 0), finish: DateTime.new(2015, 03, 21, 22, 00, 0), status: 'waiting')
Request.create(user_id: 3, start: DateTime.new(2015, 03, 23, 19, 00, 0), finish: DateTime.new(2015, 03, 23, 22, 00, 0), status: 'waiting')
Request.create(user_id: 4, start: DateTime.new(2015, 03, 25, 19, 00, 0), finish: DateTime.new(2015, 03, 25, 22, 00, 0), status: 'waiting')
Request.create(user_id: 5, start: DateTime.new(2015, 03, 30, 19, 00, 0), finish: DateTime.new(2015, 03, 30, 22, 00, 0), status: 'accepted')
Request.create(user_id: 1, start: DateTime.new(2015, 04, 25, 17, 00, 0), finish: DateTime.new(2015, 04, 25, 23, 00, 0), status: 'complete', babysitter_id: 2)
Request.create(user_id: 2, start: DateTime.new(2015, 04, 05, 18, 00, 0), finish: DateTime.new(2015, 04, 05, 22, 00, 0), status: 'complete')