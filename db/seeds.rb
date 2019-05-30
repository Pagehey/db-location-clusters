puts "- Cleaning DB"
Record.destroy_all

# n = 500

# print "- Creating first cluster records (#{n}) "
# n.times do
#   longitude = rand(-1..0.500000)
#   latitude  = rand(47..47.500000)
#   point     = "POINT(#{longitude} #{latitude})"

#   Record.create(
#     name: Faker::Games::Witcher.location,
#     longitude: longitude,
#     latitude:  latitude,
#     longlat:   point
#   )
#   print '.'
# end
# print " done! \n"

# print "- Creating second cluster records (#{n}) "
# n.times do
#   longitude = rand(3..4.500000)
#   latitude  = rand(49..49.500000)
#   point     = "POINT(#{longitude} #{latitude})"

#   Record.create(
#     name: Faker::Movies::StarWars.planet,
#     longitude: longitude,
#     latitude:  latitude,
#     longlat:   point
#   )
#   print '.'
# end
# print " done! \n"

(0..5).each do |lng|
  (43..48).each do |lat|
    20.times do
      longitude = lng + rand(0.5..0.70000)
      latitude  = lat + rand(0.5..0.70000)
      point     = "POINT(#{longitude} #{latitude})"
      Record.create(
        name: Faker::Movies::StarWars.planet,
        longitude: longitude,
        latitude:  latitude,
        longlat:   point
      )
    end
  end
end

# n2 = 2000
# print "- Creating records everywhere in France (#{n2}) "
# n2.times do
#   longitude = rand(-0.255000..5.80000)
#   latitude  = rand(44.17000..49.07000)
#   point     = "POINT(#{longitude} #{latitude})"

#   Record.create(
#     name: Faker::TvShows::GameOfThrones.city,
#     longitude: longitude,
#     latitude:  latitude,
#     longlat:   point
#   )
#   print '.'
# end
# print " done! \n"

# rand(-0.255000..5.80000)
# rand(44.17000..49.07000)
