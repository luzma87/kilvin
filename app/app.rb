require 'sinatra'
require 'sinatra/multi_route'
require 'sinatra/cross_origin'
require 'rack-flash'
require 'tilt/erb'
require 'mongoid'
require 'sinatra/r18n'

require_relative 'domains/Page'
require_relative 'domains/user'

class App < Sinatra::Application
  helpers Sinatra::Helpers

  configure { set :server, :puma }

  configure do
    Mongoid.load!('config/mongoid.yml')
  end

  set :session_secret, 'ENHAsvDgMTp3GcJEKMEE2cHFPH7ad7ZV'
  use Rack::Session::Cookie, key: '_rack_session', path: '/', expire_after: 2_592_000,
      secret: settings.session_secret
  use Rack::Flash, sweep: true

  # set folder for templates to ../views, but make the path absolute
  set :views, File.expand_path('../views', __FILE__)

  # don't enable logging when running tests
  configure :production, :development do
    enable :logging
  end

  register Sinatra::CrossOrigin

  configure do
    enable :cross_origin
  end

  set :allow_origin, :any

  options '*' do
    headers = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
    response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = headers
    status 204
  end

  before do
    session[:locale] = params[:locale] ? params[:locale] : 'en'
  end

  get '/pages/?' do
    @pages = Page.all
    p @pages
    p @pages.first

    user = User.create
    user.valid?
    p '....................................'
    p user.errors
    p ' '
    p user.errors.messages
    p ' '
    p user.errors.full_messages
    p '....................................'
    erb :index

    # JSON.dump(status: 'OK', pages: @pages.to_json)
  end

  get '/pages/new' do
    Page.create(title: 'generated title', content: 'generated content')
    redirect '/pages'
  end

  get '/floramo/?' do
    arr_of_arrs = CSV.read('floramo.csv')
    p arr_of_arrs
    arr_of_arrs[0..arr_of_arrs.length].each do |x|
      # operation here
    end
  end

end
