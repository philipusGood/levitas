# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

def create_user(role = 'broker')
  user = User.new(role: role)
  user.skip_password_validation = true
  user.email = Faker::Internet.email
  user.title = Faker::Name.prefix
  user.first_name  = Faker::Name.first_name
  user.last_name = Faker::Name.last_name
  user.middle_name = Faker::Name.middle_name
  user.birth_date = '28-09-1990'
  user.phone_number = Faker::PhoneNumber.phone_number
  user.address_street = Faker::Address.street_address
  user.address_unit = Faker::Address.secondary_address
  user.address_city = Faker::Address.city
  user.address_province = Faker::Address.state
  user.address_country = Faker::Address.country
  user.address_postal_code = Faker::Address.zip_code
  user.password = "Passw@rd123_"
  user.password_confirmation = "Passw@rd123_"
  user.save!
end

100.times do
  create_user
  create_user('lender')
end
