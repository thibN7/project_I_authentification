$: << File.dirname(__FILE__)

require 'sinatra'

set :port, 2000

#enable :sessions

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
		erb :"protected"
	else
		redirect 'http://localhost:4567/appli_1/sessions/new?origine=/protected'
	end
end
