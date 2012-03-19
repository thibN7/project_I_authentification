require_relative 'spec_helper'

#ENV['RACK_ENV'] = 'test'

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

	before :all do
		clear_cookies
	end

	describe "Get available pages" do

		it "should get the root page /" do
			get '/'
			last_response.should be_ok
		end

		it "it should get the page /users/new" do
			get '/users/new'
			last_response.should be_ok
		end

		it "it should get the page /sessions/new" do
			get '/sessions/new'
			last_response.should be_ok
		end

		it "it should get the page /applications/new" do
			get '/applications/new'
			last_response.should be_ok
		end

		it "it should get the page /sessions/disconnect" do
			get '/sessions/disconnect'
			last_response.should be_redirect
   		follow_redirect!
    	last_request.path.should == '/'
		end

		describe "/s_auth/application/delete" do

			it "should rerender the form if a session exists" do
				session = {'rack.session'=> {:current_user => 'toto'} }
				get '/s_auth/application/delete', {}, session
				#TODO : comment faire lorsqu'un erb suivi d'un redirect ?
				puts last_request.env['rack.session'][:current_user]
				#last_response.should be_ok
			end

			it "should redirect the user to the index page if session doesn't exist" do
				get '/applications/delete'
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

		describe "get /users/new" do

			it "should return a form to post registration info" do
		  	get '/users/new'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/users".*method="post".*}
			end

		end


		describe "post /users" do

			describe "Registration available" do

				before(:each) do
					@user = double(User)
					User.stub(:create){@user}
					@user.stub(:valid?).and_return(true)
          @user.stub(:login){"tmorisse"}
					#@session = {'rack.session'=> {:current_user => 'toto'} }
				end

				it "should create a new user" do
					User.should_receive(:create).with(@params)
					@user.should_receive(:valid?).and_return(true)
					post '/users', @params
					print last_response.body
					last_request.env["rack.session"][:current_user].should == "tmorisse"
				
				end

				it "should define a cookie" do
					User.should_receive(:create).with(@params)
					@user.should_receive(:valid?).and_return(true)
					post '/users', @params
					last_response.headers["Set-Cookie"].should be_true



				end

				it "should return to the root page" do
					@user.stub(:login).and_return("tmorisse")
					@user.should_receive(:valid?).and_return(true)
					post '/users'
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
					#TODO : stuber pour afficher les erreurs
				end

				it "should rerender the registration form" do 
					@user.should_receive(:valid?).and_return(false)
					post '/users', @params
					last_response.should be_ok
					last_response.body.should match %r{<form.*action="/users".*method="post".*}
				end

			end

		end
		
	end	# END USER REGISTRATION


	# USER AUTHENTICATION
	describe "User Authentication" do

		describe "get /sessions/new" do
			it "should return a form to post authentication info" do
		  	get '/sessions/new'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
			end
		end

		describe "post /sessions" do

			before(:each) do
				@params = {'login' => 'tmorisse','password' => 'passwordThib'}
				@user = double(User)
				User.stub(:find_by_login).and_return(@user)
				@user.stub(:login){'tmorisse'}
				User.stub(:user_exists).and_return(@user)
			end

			describe "Authentication ok" do

				before(:each) do
					User.should_receive(:user_exists).with(@params['login'],@params['password']).and_return(true)
				end
				
				it "should redirect the user to the index page" do
					post '/sessions', @params
          last_response.should be_redirect
					follow_redirect!
					last_request.path.should == '/'
				end

				it "should store the login of the user into the session" do
					post '/sessions', @params
					last_request.env["rack.session"][:current_user].should == "tmorisse"
				end				

			end			

			describe "Authentication not ok" do

				before(:each) do
					User.should_receive(:user_exists).with(@params['login'],@params['password']).and_return(false)
				end

				it "should rerender the form if the user is unknown" do
					@user.stub(:nil?).and_return(true)
					post '/sessions', @params
					last_response.should be_ok
		    	last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
				end

				it "should rerender the form if the password is wrong" do
					@user.stub(:nil?).and_return(false)
					post '/sessions', @params
					last_response.should be_ok
		    	last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
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

		describe "get /applications/new" do
			it "should return a form to post registration application" do
		  	get '/applications/new'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/applications".*method="post".*}
			end
		end

		describe "post /applications" do
	
			describe "Registration application ok" do
				
				before(:each) do
					@appli = double(Application)
					Application.stub(:create).and_return(@appli)
					@appli.stub(:valid?).and_return(true)
					#post '/users', @paramsUser
					@u = double (User)
					User.stub(:find_by_login){@u}
					@u.stub(:id)
					
				end

				after(:each) do
					get '/sessions/disconnect'
					#'rack.session'=> {:current_user => nil}
				end

				it "the user has to be connected" do
					post '/applications',{},"rack.session" => { :current_user => "tmorisse" }
					last_request.env["rack.session"][:current_user].should == "tmorisse"
				end

				it "should redirect the user to the index" do
					post '/applications',{},"rack.session" => { :current_user => "tmorisse" }
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
					@u = double (User)
					User.stub(:find_by_login){@u}
					@u.stub(:id)
				end

				it "should rerender the form if the application is not valid" do
					#post '/users', @paramsUser
					post '/applications',{},"rack.session" => { :current_user => "tmorisse" }
					last_response.should be_ok
		    	last_response.body.should match %r{<form.*action="/applications".*method="post".*}
					get '/sessions/disconnect'
				end

			end		

		end

	end # END APPLICATION REGISTRATION


	# DELETE AN APPLICATION
	describe "Delete an application" do 

		describe "The user is connected" do

			before(:each) do
				@paramsUser = {'login' => 'tmorisse','password' => 'passwordThib'}
				@paramsAppli = {'name' => 'nomAppli','url' => 'http://urlAppli.fr'}
				@session = {'rack.session'=> {:current_user => 'tmorisse'}}
				#post '/users', @paramsUser
        @u=double(User)
 				User.stub(:find_by_login){@u}
				@u.stub(:id){1}
			end

			after(:each) do
				get '/sessions/disconnect'
			end

			it "should rerender the index page when an application is deleted" do
				get '/applications/delete?appli=1', {}, @session
        last_request.env["rack.session"][:current_user].should == "tmorisse"
				#TODO : comment tester Application.delete(params['app'], current_user) ?
				#puts last_response.body
				last_response.should be_ok
			end


			it "should rerender the index page when the user is not the owner" do
				get '/s_auth/application/delete', {}, @session
				last_request.env["rack.session"][:current_user].should == "tmorisse"
				
				#TODO
			end

		end


		describe "The user is not connected" do

			it "should redirect the user to the index page" do
				get '/applications/delete'
				last_response.should be_redirect
				follow_redirect!
				last_request.path.should == '/'
			end

		end
		


	end
	# END DELETE AN APPLICATION




	describe "Disconnection" do	# DISCONNECTION

		it "should disconnect the user by cleaning the session" do
			#TODO : comment faire ?
		end

		it "should redirect the user to the index" do
			get '/sessions/disconnect'
			last_response.should be_redirect
			follow_redirect!
			last_request.path.should == '/'
		end

		

	end	# END DISCONNECTION




	describe "User authentication for a client application" do
		
		describe "get '/:appli/sessions/new'" do

			before(:each) do
				@appli = double(Application)
				Application.stub(:find_by_name){@appli}
				@user = double(User)
				User.stub(:find_by_login){@user}
				@appli.stub(:url){'http://www.appliCliente.fr'}
				@params = {"origin"=>"/protected"}
				@session = { "rack.session" => { :current_user => "tmorisse" } }
			end
	

			describe "The user is connected" do
		
				before(:each) do
					Application.stub(:redirect){'http://www.appliCliente.fr/protected'}
				end

				it "should get an application thanks to its name" do
					Application.should_receive(:find_by_name).with('appli_1')
					get '/appli_1/sessions/new', @params, @session
				end
			
				it "should redirect the user to the origin page of the application" do
					get '/appli_1/sessions/new', @params, @session
					last_response.should be_redirect
					follow_redirect!
					last_request.url.should == 'http://www.appliCliente.fr/protected'
				end

			end


			describe "The user is not connected" do

				it "should render the form which allows the user to authenticate on the authentication service " do
					get '/appli_1/sessions/new', @params
					last_response.should be_ok
				end

			end

		end

		describe "post '/:appli/sessions'" do



		end

	end





end
