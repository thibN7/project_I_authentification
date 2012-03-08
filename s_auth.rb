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
	user=User.new
	user.login = params[:login]
  user.password = params[:password]
  user.save
	if user.valid?
		redirect 's_auth/registered'
	else
		# A FAIRE
		errlog = u.errors.messages[:login]
	  errpass = u.errors.messages[:password]
		if errlog.include?("has already been taken")
			redirect "/s_auth/register?error=Login_already_taken. Please entry an another one."
		elsif errlog.include?("can't be blank")
			redirect "/s_auth/register?error=The login is empty.Please_entry_a_login."
		else
			redirect "/s_auth/register?error=Test dans tous les cas"
		end
	end
end

get '/s_auth/registered' do
	erb :'s_auth/registered'
end





