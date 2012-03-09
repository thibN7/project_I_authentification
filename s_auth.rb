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
  u = User.create(params['user'])
  if u
    redirect "/s_auth/register/#{params['user']['login']}"
  else
    erb :"s_auth/register"
  end
end

get "/s_auth/register/:login" do
  "bonjoun #{login}"
end



