$: << File.dirname(__FILE__)

require 'sinatra'

set :port, 2000

enable :sessions

#-----------------------
# HELPERS
#-----------------------
helpers do 

  def current_user_appli
    session[:current_user_appli]
  end

end


#-----------------------
# GET METHODS
#-----------------------

# GET /
get '/' do
	erb :"index"
end


# GET /PROTECTED
get '/protected' do
	if params['secret'] == "iamsauth" && !params['login'].nil?
		session[:current_user_appli] = params['login']
	end
	if !current_user_appli.nil?
		@login = current_user_appli
		erb :"protected"
	else
		redirect 'http://localhost:4567/sessions/new/appli_1?origine=/protected'
	end
end


# NOT FOUND
not_found do
  erb :"errors/not_found"
end
