require 'spec_helper'
require 'uri'

require '../appli_2'



describe "Client Application" do

	# GET /
	describe "get /" do

		it "should get /" do
			get '/'
			last_response.should be_ok
			last_request.path.should == '/'
		end

		it "should return a form to post index page" do
			get '/'
			last_response.body.should match %r{<title>Client Application</title>.*}
		end

	end

	# GET /protected
	describe "get /protected" do

		before(:each) do
			@params = { 'secret' => 'iamsauth', 'login' => 'tmorisse' }
		end

		describe "Authentication service secret" do

			describe "The secret is the secret defined by the s_auth" do

				it "should create a session" do
					get '/protected', @params
					last_request.env["rack.session"][:current_user_appli].should == "tmorisse"
				end

			end		

			describe "The secret is not the secret defined by the s_auth" do
			
				it "should not create a session" do
					@params['secret'] = "iamnotsauth"
					get '/protected', @params
					last_request.env["rack.session"][:current_user_appli].should be_nil
				end

			end

		end


		describe "The login is present as url parameter" do

			it "should not exist a current_user" do
				get '/protected'
				last_request.env["rack.session"][:current_user_appli].should be_nil
			end

			it "should get /protected" do
				get '/protected', @params
				last_response.should be_ok
				last_request.path.should == '/protected'
			end

			it "should return a form to post protected page" do
				get '/protected', @params
				last_response.body.should match %r{<title>Protected Page of the Client Application</title>.*}
			end
	
		end


		describe "The current_user (session) exits" do

			before(:each) do
				@session = { "rack.session" => { :current_user_appli => "tmorisse" } }
			end

			it "should exist a current_user" do
				get '/protected', {}, @session
				last_request.env["rack.session"][:current_user_appli].should == "tmorisse"
			end

			it "should get /protected" do
				get '/protected', {}, @session
				last_response.should be_ok
				last_request.path.should == '/protected'
			end

			it "should return a form to post protected page" do
				get '/protected', {}, @session
				last_response.body.should match %r{<title>Protected Page of the Client Application</title>.*}
			end

		end


		describe "The current_user (session) doesn't exist" do

			it "should not exist a current_user" do
				get '/protected'
				last_request.env["rack.session"][:current_user_appli].should be_nil
			end

			it "should redirect to the authentication service" do
				get '/protected'
				last_response.should be_redirect
		   	follow_redirect!
		   	last_request.url.should == 'http://localhost:4567/sessions/new/appli_2?origine=%2Fprotected'
			end

		end
	
	end

	# GET /sessions/disconnect
	describe "get /sessions/disconnect" do

		before(:each) do
			get '/sessions/disconnect'
		end
	
		it "should disconnect the user by cleaning the session" do
			last_request.env["rack.session"][:current_user_appli].should be_nil
		end

		it "should redirect the user to the index page" do
			last_response.should be_redirect
			follow_redirect!
			last_request.path.should == '/'
		end
	
	end




end
