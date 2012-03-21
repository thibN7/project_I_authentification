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
	if current_user == params['login']
		erb :"users/profil"
	else
		#TODO
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
		#TODO
	end
end

# POST
post '/applications' do
	user = User.find_by_login(current_user)

	#TODO : create
	#EXEMPLE : User.create(:first_name => 'Jamie')

	name = params['application_name']
  url = params['application_url']
  user_id = user.id

  #params = { 'application' => {"name" => name, "url" => url, "user_id" => uid}}

  appli = Application.create("name" => name, "url" => url, "user_id" => user_id)


end

#GET DELETE
get '/applications/delete' do
	if current_user
		Application.delete(params['appli'], current_user)
	else

	end
end
















