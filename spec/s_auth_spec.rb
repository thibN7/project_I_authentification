require_relative 'spec_helper'

require '../s_auth'
require 'rack/test'

describe "Application" do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

	before(:each) do
		User.all.each{|user| user.destroy}
		Application.all.each{|appli| appli.destroy}
	end

	after(:each) do
		User.all.each{|user| user.destroy}
		Application.all.each{|appli| appli.destroy}
	end

	describe "Get pages" do

		it "/" do
			get '/'
			last_response.should be_ok
		end

		it "/s_auth/registration" do
			get '/s_auth/registration'
			last_response.should be_ok
		end

		it "/s_auth/authentication" do
			get '/s_auth/authentication'
			last_response.should be_ok
		end

		it "/s_auth/registration_application" do
			get '/s_auth/registration_application'
			last_response.should be_ok
		end

		it "/sessions/deco" do
			get '/sessions/deco'
			last_response.should be_redirect
   		follow_redirect!
    	last_request.path.should == '/'
		end

		describe "/s_auth/application/delete" do

			it "should rerender the form if a session exists" do
				get '/s_auth/application/delete'
				#TODO : comment faire lorsqu'un erb suivi d'un redirect ?
			end

			it "should redirect the user to the index page if session doesn't exist" do
				get '/s_auth/application/delete'
				last_response.should be_redirect
		 		follow_redirect!
		  	last_request.path.should == '/'
			end

			
		end



	end

	# USER REGISTRATION
	describe "User registration" do

		before(:each) do
			@params = {'login' => 'tmorisse','password' => 'passwordThib'}
		end

		describe "get /s_auth/registration" do

			it "should return a form to post registration info" do
		  	get '/s_auth/registration'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/s_auth/registration".*method="post".*}
			end

		end


		describe "post /s_auth/registration" do

			describe "Registration available" do

				before(:each) do
					@user = double(User)
					User.stub(:create){@user}
					@user.stub(:valid?).and_return(true)
				end

				it "should create a new user" do
					User.should_receive(:create).with(@params)
					@user.should_receive(:valid?).and_return(true)
					post '/s_auth/registration', @params
				end

				it "should return to the root page" do
					@user.stub(:login).and_return("tmorisse")
					@user.should_receive(:valid?).and_return(true)
					post '/s_auth/registration'
					last_response.should be_redirect
       		follow_redirect!
        	last_request.path.should == '/'
				end

			end

			describe "Registration not available" do
			
				before(:each) do
					@user = double(User)
					User.stub(:create){@user}
					@user.stub(:valid?).and_return(false)
					#@errors = double("Errors")
					#@user.stub(:errors).and_return(@errors)
					#@errors.stub(:messages).and_return("Error message")
				end

				it "should rerender the registration form" do 
					@user.should_receive(:valid?).and_return(false)
					post '/s_auth/registration', @params
					last_response.should be_ok
					last_response.body.should match %r{<form.*action="/s_auth/registration".*method="post".*}
				end

			end

		end

	

		
		
	end	# END USER REGISTRATION


	describe "User Authentication" do

		# Create a user before each test
		before(:each) do
			@params = {'login' => 'tmorisse','password' => 'passwordThib'}
		end

		describe "get /s_auth/authentication" do
			it "should return a form to post authentication info" do
		  	get '/s_auth/authentication'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/s_auth/authentication".*method="post".*}
			end
		end

		describe "post /s_auth/authentication" do

			describe "Authentication ok" do
				
				before(:each) do
					@user = double(User)
					User.stub(:user_exists).and_return(@user)
					@user.stub(:nil?).and_return(false)
					@user.stub(:login){"tmorisse"}
				end

				it "should redirect the user to the index page" do
					User.should_receive(:user_exists).with(@params['login'],@params['password']).and_return(true)
					post '/s_auth/authentication', @params
          last_response.should be_redirect
					follow_redirect!
					last_request.path.should == '/'
				end

				it "should store the login of the user into the session" do
					post '/s_auth/authentication', @params
					last_request.env["rack.session"]["current_user"].should == "tmorisse"
				end				

			end			

			describe "Authentication not ok" do

				before(:each) do
					@user = double(User)
					User.stub(:find_by_login).and_return(@user)
					@user.stub(:nil?).and_return(true)
				end

				it "should rerender the form" do
					post '/s_auth/authentication'
					last_response.should be_ok
		    	last_response.body.should match %r{<form.*action="/s_auth/authentication".*method="post".*}
				end
			end

		end

	end

	describe "Application registration" do # APPLICATION REGISTRATION

		# Create a user before each test
		before(:each) do
			@paramsUser = {'login' => 'tmorisse','password' => 'passwordThib'}
			@paramsAppli = {'name' => 'nomAppli','url' => 'http://urlAppli.fr'}
		end

		describe "get /s_auth/registration_application" do
			it "should return a form to post registration application" do
		  	get '/s_auth/registration_application'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/s_auth/registration_application".*method="post".*}
			end
		end

		describe "post /s_auth/registration_application" do
	
			describe "Registration application ok" do
				
				before(:each) do
					@appli = double(Application)
					Application.stub(:create).and_return(@appli)
					@appli.stub(:valid?).and_return(true)
				end

				it "the user has to be connected" do
					post '/s_auth/registration', @paramsUser
					last_request.env["rack.session"]["current_user"].should == "tmorisse"
				end

				it "should redirect the user to the index" do
					post '/s_auth/registration', @paramsUser
					post '/s_auth/registration_application'
					last_response.should be_redirect
					follow_redirect!
					last_request.path.should == '/'
				end
				

			end

			describe "Registration application not ok" do

				before(:each) do
					#@user = double(User)
					@appli = double(Application)
					Application.stub(:create).and_return(@appli)
					@appli.stub(:valid?).and_return(false)
				end

				it "should rerender the form if the application is not valid" do
					post '/s_auth/registration', @paramsUser
					post '/s_auth/registration_application'
					last_response.should be_ok
		    	last_response.body.should match %r{<form.*action="/s_auth/registration_application".*method="post".*}
				end

			end		

		end

	end # END APPLICATION REGISTRATION


	describe "Delete an application" do 

		describe "The user is connected" do

			before(:each) do
				@paramsUser = {'login' => 'tmorisse','password' => 'passwordThib'}
				@paramsAppli = {'name' => 'nomAppli','url' => 'http://urlAppli.fr'}
				post '/s_auth/registration', @paramsUser
			end

			it "should rerender the index page when an application is deleted" do
				last_request.env["rack.session"]["current_user"].should == "tmorisse"
				get '/s_auth/application/delete'
				#TODO : comment tester Application.delete(params['app'], current_user) ?
				#puts last_response.body
				last_response.should be_ok
			end


			it "should rerender the index page when the user is not the owner" do
				last_request.env["rack.session"]["current_user"].should == "tmorisse"
				get '/s_auth/application/delete'
				#TODO
			end

		end


		describe "The user is not connected" do

			it "should redirect the user to the index page" do
				get '/s_auth/application/delete'
				last_response.should be_redirect
				follow_redirect!
				last_request.path.should == '/'
			end

		end





	end













	describe "Disconnection" do	# DISCONNECTION

		it "should disconnect the user by cleaning the session" do
			#TODO : comment faire ?
		end

		it "should redirect the user to the index" do
			get '/sessions/deco'
			last_response.should be_redirect
			follow_redirect!
			last_request.path.should == '/'
		end

	end	# END DISCONNECTION




end
