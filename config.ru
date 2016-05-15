require 'sinatra/base'
require_relative 'app/app'

# pull in the helpers and controllers
Dir.glob('./app/{helpers,controllers}/*.rb').each { |file| require file }

map('/public') { run Rack::Directory.new('./app/public') }
# map the controllers to routes
map('/') { run App }
