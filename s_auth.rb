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
		response.set_cookie("sauth", {:value => '', :expires => Time.at(0), :path => '/'})
  end
end

# ROOT PAGE
get '/' do
	if !current_user.nil?
		user = User.find_by_login(current_user)
		@user_id = user.id
	else
		if !request.cookies["sauth"].nil?
			user = User.find_by_login(request.cookies["sauth"])
			session[:current_user] = user.login
			@user_id = user.id
		end
	end
	erb :index
end

#------------------------------
# USER REGISTRATION PAGE
#------------------------------

# GET
get '/users/new' do
	erb :"s_auth/registration"
end

# POST
post '/users' do
	user = User.create('login' => params['login'], 'password' => params['password'])
	if user.valid?
		session[:current_user] = user.login
		response.set_cookie("sauth", {:value => current_user, :expires => Time.parse(Date.today.next_day(7).to_s), :path => '/'})	
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
get '/sessions/new' do
	erb :"s_auth/authentication"
end

# POST
post '/sessions' do
	if User.user_exists(params['login'],params['password'])
		session[:current_user] = params['login']
		response.set_cookie("sauth", {:value => current_user, :expires => Time.parse(Date.today.next_day(7).to_s), :path => '/'})	
		redirect '/'
	else
		user = User.find_by_login(params['login'])
		if user.nil?
			@authentication_error = :unknown_user
		else
			@authentication_error = :match_password
		end
		@login = params['login']
		erb :"s_auth/authentication"
	end
end

#------------------------------
# APPLICATION REGISTRATION PAGE
#------------------------------

# GET
get '/applications/new' do
	erb :"s_auth/registration_application"
end

# POST
post '/applications' do
	user = User.find_by_login(current_user)
	appli = Application.create('name' => params['application_name'], 'url' => params['application_url'], 'user_id' => user.id)
	if !current_user.nil?
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

# GET
get "/applications/delete" do
  if !current_user.nil?
    Application.delete(params['appli'], current_user)
		user = User.find_by_login(current_user)
		@user_id = user.id
		erb :"index"
	else
    redirect '/'
  end
end


#------------------------
# DISCONNECTION
#------------------------
get '/sessions/disconnect' do
	disconnect
	redirect '/'
end







