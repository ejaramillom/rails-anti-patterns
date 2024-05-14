# bad (login actions in users controller)

class UsersController < ApplicationController
  def login
    if request.post?
      if session[:user_id] = User.authenticate(params[:user][:login],
        params[:user][:password])
        flash[:message] = "Login successful"
        redirect_to root_url
      else
        flash[:warning] = "Login unsuccessful"
      end
    end
  end
  
  def logout
    session[:user_id] = nil
    flash[:message] = 'Logged out'
    redirect_to :action => 'login'
  end
  
  ... RESTful actions ...
end

# better
# define the resources
resource :sessions, :only => [:new, :create, :destroy]
match "/login" => "user_sessions#new", :as => :login
match "/logout" => "user_sessions#destroy", :as => :logout

# set the behaviors independently

class SessionsController < ApplicationController
  def new
    # Just render the sessions/new.html.erb template
  end
    
  def create
    if session[:user_id] = User.authenticate(params[:user][:login],
      params[:user][:password])
      flash[:message] = "Login successful"
      redirect_to root_url
    else
      flash.now[:warning] = "Login unsuccessful"
      render :action => "new"
    end
  end
    
  def destroy
    session[:user_id] = nil
    flash[:message] = 'Logged out'
    redirect_to login_url
  end
end

# You see, new and edit are not really RESTful actions. At its core, REST asks for only the index , create , show , update , and destroy actions.
