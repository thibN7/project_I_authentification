# encoding: UTF-8

$: << File.join(File.dirname(__FILE__))

require 'sinatra'

require 'lib/user.rb'

require 'database.rb'


enable :sessions

# HELPERS
helpers do 
  def current_user
    session[:current_user]
  end

  def disconnect
    session[:current_user] = nil
  end
end

# ROOT PAGE
get '/' do
	if !current_user.nil?
		user = User.find_by_login(current_user)
		@user_id = user.id
	end
	erb :index
end

#------------------------------
# USER REGISTRATION PAGE
#------------------------------

# GET
get '/s_auth/registration' do
	erb :"s_auth/registration"
end

# POST
post '/s_auth/registration' do

	user = User.create('login' => params['login'], 'password' => params['password'])
	
	if user.valid?
		session[:current_user] = user.login		
		@user = user.login
		redirect '/'
	else
		#@registration_error = user.errors.messages
		erb :"s_auth/registration"
	end
end


#------------------------------
# USER AUTHENTICATION PAGE
#------------------------------

# GET
get '/s_auth/authentication' do
	erb :"s_auth/authentication"
end

# POST
post '/s_auth/authentication' do
	if User.user_exists(params['login'],params['password'])
		session[:current_user] = params['login']	
		redirect '/'
	else
		#@authentication_error = :unknown_user
		erb :"s_auth/authentication"
	end
end

#------------------------------
# APPLICATION REGISTRATION PAGE
#------------------------------

# GET
get '/s_auth/registration_application' do
	erb :"s_auth/registration_application"
end

# POST
post '/s_auth/registration_application' do
	user = User.find_by_login(current_user)
	appli = Application.create('name' => params['application_name'], 'url' => params['application_url'], 'user_id' => user.id)
	if current_user
		if appli.valid?
			redirect '/'
		else
			erb :"s_auth/registration_application"
		end
	else
		redirect '/'
	end
end


#------------------------
# Delete an application
#------------------------
get "/s_auth/application/delete" do
  if current_user
    Application.delete(params['appli'], current_user)
		erb :"index"
	else
    redirect '/'
  end
end


#------------------------
# DISCONNECTION
#------------------------
get '/sessions/deco' do
	disconnect
	redirect '/'
end







