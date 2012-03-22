# encoding: UTF-8

$: << File.join(File.dirname(__FILE__))

require 'sinatra'

require 'lib/user.rb'

require 'database.rb'


#use Rack::Session::Pool
#enable :sessions

#-----------------------
# HELPERS
#-----------------------
helpers do 

  def current_user
    session[:current_user]
  end

  def disconnect
    session[:current_user] = nil
  end

end

#-----------------------
# INDEX PAGE
#-----------------------

#GET
get '/' do
	erb :"index"
end


#-----------------------
# USER REGISTRATION
#-----------------------

# GET 
get '/users/new' do
	erb :"users/new"
end

# POST
post '/users' do
	user = User.create('login' => params['login'], 'password' => params['password'])
	if user.valid?
		redirect '/sessions/new'
	else
		#TODO : stuber user.errors.messages
		#@registration_error = user.errors.messages
		erb :"users/new"
	end
end


#-----------------------
# USER AUTHENTICATION
#-----------------------

# GET 
get '/sessions/new' do
	erb :"sessions/new"
end

# POST
post '/sessions' do
	user = User.find_by_login(params['login'])
	if User.user_exists(params['login'],params['password'])
		session[:current_user] = params['login']
		redirect '/'
	else
		if user.nil?
			@authentication_error = :unknown_user
		else
			@authentication_error = :match_password
		end
		@login = params['login']
		erb :"sessions/new"
	end
end


#------------------------
# DISCONNECTION
#------------------------

# GET
get '/sessions/disconnect' do
	disconnect
	redirect '/'
end


#------------------------
# USER PAGES
#------------------------

# GET
get '/users/:login' do
	if current_user == params[:login]
		user = User.find_by_login(current_user)
		@applications = Application.where(:user_id => user.id)
		erb :"users/profil"
	else
		@error_forbidden = :current_user_match_login
		erb :"errors/forbidden"
	end
end


#----------------------------
# APPLICATION REGISTRATION
#----------------------------

# GET NEW
get '/applications/new' do
	if current_user 
		erb :"applications/new"
	else
		@error_forbidden = :current_user_nil
		erb :"errors/forbidden"
	end
end

# POST
post '/applications' do
	user = User.find_by_login(current_user)
  appli = Application.create("name" => params['name'], "url" => params['url'], "user_id" => user.id)
	if appli.valid?
		redirect '/users/'+current_user
	else
		#TODO 
		#@registration_error = appli.errors.messages
		erb :"/applications/new"
	end
end

#GET DELETE
get '/applications/delete/:name' do
	if current_user
		appli = Application.find_by_name(params[:name])
		if !appli.nil?
			user = User.find_by_login(current_user)
			if user.id == appli.user_id
				Application.delete(appli)
				redirect '/users/'+current_user
			else
				@error_forbidden = :user_id_appli_user_id_match
				erb :"errors/forbidden"
			end
		else
			@error = :appli_doesnt_exist
			erb :"errors/not_found"
		end
	else
		@error_forbidden = :current_user_nil
		erb :"errors/forbidden"
	end

end
















