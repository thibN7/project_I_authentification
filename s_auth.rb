# encoding: UTF-8

$: << File.join(File.dirname(__FILE__))

require 'sinatra'

require 'lib/user.rb'

require 'database.rb'


enable :sessions

helpers do 
  def current_user
    session[:current_user]
  end

  def disconnect
    session[:current_user] = nil
  end
end


get '/' do
	if session[:current_user].nil?
		erb :not_connected
	else
    @user = User.find_by_login(session[:current_user])
		erb :connected
	end
end

get '/s_auth/registration' do
	erb :"s_auth/registration"
end

post '/s_auth/registration' do

	user = User.create('login' => params['login'], 'password' => params['password'])
	
	if user.valid?
		session[:current_user] = user.login
		redirect '/'
	else
		#@registration_error = user.errors.messages
		erb :"/s_auth/registration"
	end
end


get '/s_auth/authentication' do
	erb :"s_auth/authentication"
end


post '/s_auth/authentication' do
	user = User.find_by_login(params['login'])
	if user.nil?
		@authentication_error = :unknown_user
		erb :"s_auth/authentication"
	else
		session[:current_user] = user.login		
		redirect '/'
	end
end

get '/s_auth/registration_application' do
	erb :"s_auth/registration_application"
end

post '/s_auth/registration_application' do
	#user = User.find_by_login(params['login'])
	appli = Application.create('name' => params['application_name'], 'url' => params['application_url'])
	if current_user
		if appli.valid?
			
		else
			erb :"s_auth/registration_application"
		end
	else
		erb :"s_auth/authentication"
	end

end










