# encoding: UTF-8

$: << File.join(File.dirname(__FILE__))

require 'sinatra'

require 'lib/user.rb'

require 'database.rb'

require 'logger'


#use Rack::Session::Pool
enable :sessions

#set :logger , Logger.new('log/connections.txt', 'weekly')

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
		@registration_error = user.errors.messages
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
		@utilizations = Utilization.where(:user_id => user.id)
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
		@registration_error = appli.errors.messages
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


#------------------------------------
# CLIENT APPLICATION AUTHENTICATION
#------------------------------------

# GET 
get '/sessions/new/:appli' do #TODO A CHANGER PAR get /sessions/new/:appli
	if Application.exists?(params[:appli])
		if current_user
			if !Utilization.exists?(current_user, params[:appli])
				Utilization.add(current_user, params[:appli])
			end
			redirection = Application.redirect(params[:appli], params[:origine], current_user) + '&secret=iamsauth'
			redirect redirection 
		else 
			#TODO : probleme dans test à cause de methode back_url, et plus precisement appli.url a l'interieur de la methode
      @back_url = Application.back_url(params[:appli], params[:origine])
			erb :"sessions/new"
		end
	else
		@error = :appli_client_doesnt_exist
		erb :"errors/not_found"
	end
end

# POST
post '/sessions/:appli' do
	if User.user_exists(params['login'], params['password'])
		session[:current_user] = params['login']
		if !Utilization.exists?(current_user, params[:appli])
			Utilization.add(current_user, params[:appli])
		end
		redirect "#{params[:back_url]}?login=#{params['login']}&secret=iamsauth"
	else
		user = User.find_by_login(params['login'])
		if user.nil?
			@authentication_error = :unknown_user
		else
			@authentication_error = :match_password
		end
		@back_url = params[:back_url]
		@login = params['login']
		erb :"sessions/new"
	end
end


# NOT FOUND
not_found do
  erb :"errors/not_found"
end




