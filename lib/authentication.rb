# encoding: UTF-8

require 'sinatra'
$: << File.join(File.dirname(__FILE__),"","middleware")
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

get '/sauth/register' do
	error=params[:error]
	erb :"sauth/register", :locals => {:error => error}
end






