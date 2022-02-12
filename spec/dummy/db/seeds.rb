# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(name: "ActiveManageable User", locale: "en-GB", time_zone: "London", email: "hello@circle-sd.com")

label = Label.create!(name: "Factory Records")
artist = Artist.create!(name: "New Order")
album = Album.create!(name: "Power, Corruption & Lies", label: label, artist: artist, genre: Album.genres[:electronic], released_at: "1983-01-01")
Song.create!(name: "5 8 6", album: album)
Song.create!(name: "Ecstacy", album: album)
Album.create!(name: "Low-Life", label: label, artist: artist, genre: Album.genres[:electronic], released_at: "1985-01-01")
Album.create!(name: "Brotherhood", label: label, artist: artist, genre: Album.genres[:electronic], released_at: "1986-01-01")
Album.create!(name: "Substance", label: label, artist: artist, genre: Album.genres[:electronic], released_at: "1987-01-01")
Album.create!(name: "Technique", label: label, artist: artist, genre: Album.genres[:electronic], released_at: "1988-01-01")

label = Label.create!(name: "Atlantic Records")
artist = Artist.create!(name: "Led Zeppelin")
Album.create!(name: "Led Zeppelin", label: label, artist: artist, genre: Album.genres[:rock], released_at: "1969-01-01")
Album.create!(name: "Led Zeppelin II", label: label, artist: artist, genre: Album.genres[:rock], released_at: "1969-01-01")
Album.create!(name: "Led Zeppelin III", label: label, artist: artist, genre: Album.genres[:rock], released_at: "1970-01-01")
Album.create!(name: "Led Zeppelin IV", label: label, artist: artist, genre: Album.genres[:rock], released_at: "1971-01-01")
Album.create!(name: "Houses of the Holy", label: label, artist: artist, genre: Album.genres[:rock], released_at: "1973-03-28")
label = Label.create!(name: "Swan Song")
Album.create!(name: "Physical Graffiti", label: label, artist: artist, genre: Album.genres[:rock], released_at: "1975-02-24")
