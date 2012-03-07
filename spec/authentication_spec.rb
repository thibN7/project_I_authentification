require_relative 'spec_helper'

require 'authentication'
require 'rack/test'

describe "Authentication" do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "Scenario 1 : A user wants to register" do

		it "should be ok if a user goes to /sauth/register" do
	    get '/sauth/register'
	    last_response.should be_ok
		end

	end


end
