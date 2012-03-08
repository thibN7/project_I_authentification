require_relative 'spec_helper'

require '../s_auth'
require 'rack/test'

describe "Authentication" do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end


	context "A user is not registered" do

		context "Scenario 1 : A user wants to register" do

			it "should be ok if a user goes to /s_auth/register" do
			  get '/s_auth/register'
			  last_response.should be_ok
			end

			it "should return status 200 if a user goes to /s_auth/register" do
				get '/s_auth/register'
		    last_response.status.should == 200
			end

			it "should register a user if the login and the password are ok" do
			  params={'login' => 'tmorisse', 'password' => 'motDePasse'}
				post '/s_auth/register', params
				last_response.should be_redirect
			end

			User.all.each{|user| user.destroy}

		end

	end

	context "The login and/or the password is/are not ok" do

		it "should redirect to /s_auth/register if the password is empty" do
			params={"login" => 'tmorisse', "password" => nil}
			post '/s_auth/register', params
			#last_response.should be_redirect
			follow_redirect!
      last_request.should '/s_auth/register'
			#last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/new?info=Password_Empty'
		end

		it "should redirect to /s_auth/register if the login is empty" do
			params={"login" => nil, "password" => 'motDePasse'}
			post '/s_auth/register', params
			#last_response.should be_redirect
			follow_redirect!
	     last_request.should '/s_auth/register'
			#last_response.headers["Location"].should == 'http://example.org/s_auth/appli_cliente_1/new?info=Login_Empty'
		end

	end


end
