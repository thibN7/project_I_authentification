require_relative 'spec_helper'

require '../s_auth_2'
require 'rack/test'

describe "Application" do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

	#-----------------------
	# INDEX PAGE
	#-----------------------
	describe "Index page" do

		describe "get /" do

			it "should get /" do
				get '/'
				last_response.should be_ok
				last_request.path.should == '/'
			end

			it "should return a form to post index page" do
				get '/'
				last_response.body.should match %r{<title>Index</title>.*}
			end

		end
	
	end	
	

	#-----------------------
	# USER REGISTRATION
	#-----------------------
	describe "User registration" do

		# GET
		describe "get /users/new" do

			it "should get /users/new" do
				get '/users/new'
				last_response.should be_ok
				last_request.path.should == '/users/new'
			end

			it "should return a form to post registration info" do
		  	get '/users/new'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/users".*method="post".*}
			end

		end

		# POST
		describe "post /users" do

			before(:each) do
				@params = {'login' => 'tmorisse','password' => 'passwordThib'}
				@user = double(User)
				User.stub(:create){@user}
				User.should_receive(:create).with(@params).and_return(@user)
			end

			it "should use create method" do
				post '/users', @params
			end

			describe "Registration ok" do

				before(:each) do
					@user.stub(:valid?){true}
					@user.stub(:login){"tmorisse"}
					post '/users', @params
				end

				it "should redirect to sessions/new" do
					last_response.should be_redirect
       		follow_redirect!
					last_request.path.should == '/sessions/new'
				end

			end

			describe "Registration not ok" do

				#TODO : stuber les méthodes pour user.errors.messages

				it "should rerender the form" do
					@user.stub(:valid?){false}
					post '/users', @params
					last_response.should be_ok
					last_response.body.should match %r{<form.*action="/users".*method="post".*}
				end

			end

		end

	end
	# END USER REGISTRATION

	#--------------------------------------------------------------------

	#------------------------
	# USER AUTHENTICATION 
	#------------------------
	describe "User authentication" do

		# GET
		describe "get /sessions/new" do

			it "should get /sessions/new" do
				get '/sessions/new'
				last_response.should be_ok
				last_request.path.should == '/sessions/new'
			end

			it "should return a form to post authentication info" do
		  	get '/sessions/new'
		    last_response.should be_ok
		    last_response.body.should match %r{<form.*action="/sessions".*method="post".*}
			end

		end

		# POST
		describe "post /sessions" do

			before(:each) do
				@params = {'login' => 'tmorisse','password' => 'passwordThib'}
				User.should_receive(:find_by_login).with('tmorisse')
			end

			# Authentication ok
			describe "Authentication ok" do

				before(:each) do
					User.should_receive(:user_exists).with('tmorisse', 'passwordThib').and_return(true)
				end
				
				it "should use the user_exists method" do
					post '/sessions', @params
				end

				it "should create a session (define a cookie)" do
					post '/sessions', @params
					last_request.env["rack.session"][:current_user].should == "tmorisse"
				end

				it "should redirect to the index page" do
					post '/sessions', @params
					last_response.should be_redirect
        	follow_redirect!
        	last_request.path.should == '/'
				end

			end

			# Authentication not ok
			describe "Authentication not ok" do

				before(:each) do
					@user = double(User)
					User.should_receive(:user_exists).with('tmorisse', 'passwordThib').and_return(false)
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
	# END USER AUTHENTICATION 

	#----------------------------------------------------------------

	#-------------------------
	# USER DISCONNECTION
	#-------------------------
	describe "User disconnection" do
		
		before(:each) do
			get '/sessions/disconnect'
		end

		it "should disconnect the user by cleaning the session" do
			last_request.env["rack.session"][:current_user].should be_nil
		end

		it "should redirect to the index page" do
			last_response.should be_redirect
			follow_redirect!
			last_request.path.should == '/'
		end

	end
	# END USER DISCONNECTION

	#----------------------------------------------------------------

	#-------------------------
	# USER PAGES
	#-------------------------
	describe "User pages" do

		describe "get /users/:login" do

			it "should get /users/tmorisse" do
				get '/users/tmorisse'
				last_response.should be_ok
        last_request.path.should == '/users/tmorisse'
			end
			
			describe "The login and the current_user are the same" do

				it "should return the user page" do
					get '/users/tmorisse', {}, "rack.session" => { :current_user => "tmorisse" }
					last_response.body.should match %r{<title>User Profile</title>.*}
				end

			end

			describe "The login and the current_user are not the same" do
				#TODO
			end

		end

	end
	# END USER PAGES

	#-------------------------
	# APPLICATION
	#-------------------------
	describe "Application" do

		# GET /APPLICATIONS/NEW
		describe "get /applications/new" do
			
			describe "The current_user exists" do

				before(:each) do
					@session = { "rack.session" => { :current_user => "tmorisse" } }
				end

				it "should get /applications/new" do
					get '/applications/new', {}, @session
					last_response.should be_ok
					last_request.path.should == '/applications/new'
				end

				it "should return a form to post applications info" do
					get '/applications/new', {}, @session
				  last_response.should be_ok
				  last_response.body.should match %r{<form.*action="/applications".*method="post".*}
				end

			end

			describe "The current_user doesn't exist" do
				#TODO
			end

		end

		# POST /APPLICATIONS
		describe "post /applications" do

			before(:each) do
				@paramsUser = {'login' => 'tmorisse','password' => 'passwordThib'}
				@paramsAppli = {'name' => 'nomAppli','url' => 'http://urlAppli.fr'}
				@session = { "rack.session" => { :current_user => "tmorisse" } }
				@user = double(User)
				@appli = double(Application)
				@user.stub(:id){12}
			end
			
			it "should use find_by_login" do
				User.should_receive(:find_by_login).with('tmorisse').and_return(@user)
				post '/applications', @paramsAppli, @session
			end

			it "should use create" do
				#TODO : create

				Application.should_receive(:create).with("name"=>"appli", "url"=>"http://urlAppli.fr", "user_id"=>12).and_return(@appli)

				post '/applications', @paramsAppli, @session
			end
		
			describe "Registration ok" do

				before(:each) do
					#@appli.should_receive(:valid?).and_return(true)
				end

				it "should redirect to the user page /users/:login" do
					#post '/applications', @paramsAppli, @session
					#last_response.should be_redirect
          #follow_redirect!
          #last_request.path.should == '/users/tmorisse'
				end

			end

		end

		# GET APPLICATION/DELETE
		describe "get /application/delete/:id" do

			describe "The current_user exists" do

				before(:each) do
					@session = { "rack.session" => { :current_user => "tmorisse" } }
				end

				it "should use delete" do
					#Application.should_receive(:delete).with(12, 'tmorisse')
					#get '/application/delete?appli=12', {}, @session
				end

			end

		end

	end




end
