require 'rack/test'

require_relative '../appli_1'

include Rack::Test::Methods

def app
  Sinatra::Application
end
