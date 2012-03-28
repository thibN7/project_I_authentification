require 'rack/test'

require_relative '../appli_2'

include Rack::Test::Methods

def app
  Sinatra::Application
end
