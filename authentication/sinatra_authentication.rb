# encoding: UTF-8

require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
require 'my_middleware'

use RackCookieSession
use RackSession

helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

get '/' do
  if current_user
    "Bonjour #{current_user}"
  else
    '<a href="/sessions/new">Login</a>'
  end
end


get '/sessions/new' do
  erb :"sessions/new"
end


post '/sessions' do
	# Input : params["login"], params["password"]
	# Check if login and password match an existing user
	# YES : redirect to /protected
	if params["login"] == "titi" and params["password"] == "tata"
		session["current_user"] = params["login"]
		redirect '/protected'
		# store the user login into the session
		session["current_user"] = params["login"]
	# NO : redirect to sessions/new
	else
		session["current_user"] = nil
		redirect 'sessions/new'
	end
end


get '/protected' do
	# teste si current_user a une valeur dans la session et
	# affiche un message, sinon redirige sur GET /session/new
	if current_user
		erb :protected, :locals => { :user => current_user } # render views/protected.erb
		#"Bonjour <% :user %>"
	else
		redirect 'sessions/new'
	end
	
	
end

delete '/session/id' do
	# détruit la session de l’utilisateur identifié par id
	disconnect
	"Deconnexion"
	redirect 'sessions/new'
end


get '/sessions/deco' do
	disconnect
	redirect 'sessions/new'
end







