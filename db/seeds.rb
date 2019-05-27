Record.destroy_all

500.times do
  Record.create(
    name: Faker::Games::Witcher.location,
    longitude: rand(-1..0.500000),
    latitude: rand(47..47.500000)
  )
end

500.times do
  Record.create(
    name: Faker::Movies::StarWars.planet,
    longitude: rand(3..4.500000),
    latitude: rand(49..49.500000)
  )
end

# 49.123918, 3.840290
# (49..49.500000)
# (3..4.500000)

# 47.041268, 0.417642
# (47..47.500000)
# (-1..0.500000)
