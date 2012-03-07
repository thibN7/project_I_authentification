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
				puts "post passe"
				last_response.should be_redirect
				
			end

		end

	end

	context "The login and/or the password is/are not ok" do

		it "should redirect to /s_auth/register if the password is empty" do
				params={'login' => 'tmorisse', 'password' => ''}
				post '/s_auth/register', params
				last_response.should be_redirect
		end

		it "should redirect to /s_auth/register if the login is empty" do
				params={'login' => '', 'password' => 'motDePasse'}
				post '/s_auth/register', params
				last_response.should be_redirect
		end




	end



	context "A user is registered" do

	end





end
