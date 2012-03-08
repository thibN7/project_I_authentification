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
		puts "valid user"
	else
		# A FAIRE
		puts "invalid user"
		errorLogin = user.errors.messages[:login]
	  errorPassword = user.errors.messages[:password]
		if errorLogin.nil?
			redirect "/s_auth/register?error=The_password_is_empty.Please_entry_a_password."
		elsif errorLogin.include?("has already been taken")
			redirect "/s_auth/register?error=Login_already_taken._Please_entry_an_another_one."
		elsif errorLogin.include?("can't be blank")
			redirect "/s_auth/register?error=The_login_is_empty.Please_entry_a_login."
		end
	end
end

get '/s_auth/registered' do
	erb :'s_auth/registered'
end





