require_relative 'spec_helper'

require '../s_auth'
require 'rack/test'

describe "Authentication service" do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end


	describe "User Registration" do

		it "should return a form to post registration info" do
    	get '/s_auth/register'
      last_response.should be_ok
      last_response.body.should match %r{<form.*action="/s_auth/register".*method="post".*}
		end

		describe "The user wants to register" do

			let(:params){ { "user" => {"login" => "tmorisse", "password" => "passwordThib" }} }

			it "should create a new user" do
				User.stub(:create)
				User.should_receive(:create).with(params['user'])
				post 's_auth/register', params
			end

			it "should redirect the user just created to a private page" do
				User.stub(:create){true}
				post '/s_auth/register', params
				last_response.should be_redirect
				follow_redirect!
				last_request.path.should == '/s_auth/register/tmorisse'
			end

			it "should rerender the registration form" do
				User.stub(:create).and_return(false)
        post '/s_auth/register', params
				last_response.should be_ok
				last_response.body.should match %r{<form.*action="/s_auth/register".*method="post".*}
			end

		end


	end


	
end
