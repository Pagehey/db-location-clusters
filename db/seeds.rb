puts "- Cleaning DB"
Record.destroy_all

n = 500

print "- Creating first cluster records (#{n}) "
n.times do
  longitude = rand(-1..0.500000)
  latitude  = rand(47..47.500000)
  point     = "POINT(#{longitude} #{latitude})"

  Record.create(
    name: Faker::Games::Witcher.location,
    longitude: longitude,
    latitude:  latitude,
    longlat:   point
  )
  print '.'
end
print " done! \n"

print "- Creating second cluster records (#{n}) "
n.times do
  longitude = rand(3..4.500000)
  latitude  = rand(49..49.500000)
  point     = "POINT(#{longitude} #{latitude})"

  Record.create(
    name: Faker::Movies::StarWars.planet,
    longitude: longitude,
    latitude:  latitude,
    longlat:   point
  )
  print '.'
end
print " done! \n"
