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

# Index
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


get '/protected' do
	# teste si current_user a une valeur dans la session et
	# affiche un message, sinon redirige sur GET /session/new
	if current_user
		erb :protected, :locals => { :user => current_user } 
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







