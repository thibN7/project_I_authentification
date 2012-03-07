# encoding: UTF-8

require 'sinatra'
$: << File.join(File.dirname(__FILE__))#,"","middleware")
#require 'my_middleware'

#use RackCookieSession
#use RackSession

helpers do 
  def current_user
    session["current_user"]
  end

  def disconnect
    session["current_user"] = nil
  end
end

get '/s_auth/register' do
	error=params[:error]
	erb :"s_auth/register", :locals => {:error => error}
end

post '/s_auth/register' do
	puts "post s_auth "
	user=User.new
	user.login = params[:login]
  user.password = params[:password]
  user.save
	if user.valid?
		redirect 's_auth/registered'
	else
		# A FAIRE
	end
end

get '/s_auth/registered' do
	erb :'s_auth/registered'
end





