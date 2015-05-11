Fabricator(:request) do
  start { 2.days.from_now }
  finish { 3.days.from_now }
end