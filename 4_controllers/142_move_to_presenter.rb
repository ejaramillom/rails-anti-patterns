# bad (create two types of objects in a single controller)

class AccountsController < ApplicationController
  def new
    @account = Account.new
    @user = User.new
  end
  
  def create
    @account = Account.new(params[:account])
    @user = User.new(params[:user])
    @user.account = @account
    
    if @account.save and @user.save
      flash[:notice] = 'Account was successfully created.'
      redirect_to(@account)
    else
      render :action => "new"
    end
  end
end

# app/views/accounts/new.html.erb

<h1>New account</h1>
  <%= form_for(@account) do |f| %>
    <%= f.error_messages %>
    
    <p>
      <%= f.label :subdomain %><br />
      <%= f.text_field :subdomain %>
    </p>
    
    <%= fields_for(@user) do |u| %>
    <%= u.error_messages %>
      
    <p>
      <%= u.label :email %><br />
      <%= u.text_field :email %>
    </p>
      
    <p>
      <%= u.label :password %><br />
      <%= u.text_field :password %>
    </p>
  <% end %>
  
  <p>
    <%= f.submit "Create" %>
  </p>
<% end %>>

# one of the general guidelines we’re breaking is “Exceptions should be exceptional.” We’re now using exceptions to handle validation failures—a common and expected situation for a web application. Another guideline we’re breaking is that we’ve introduced transactions, a low-level database concept, into the Controller layer. Typically, anytime a controller is making explicit use of transactions, you’ve gone down the wrong path.

# Jay Fields, who wrote about it extensively at http://blog.jayfields.com . In this merger of MVC and MVP, the presenter sits between the Model layer and the View and Controller layers.

# You can find Active Presenter, with installation instructions, at http://github.com/jamesgolick/active_presenter

# fix (a signup presenter assigns a user to an account on account creation in CRUD actions)

# app/models/signup.rb

class Signup < ActivePresenter::Base
  before_save :assign_user_to_account
  presents :user, :account
  
  private
  
  def assign_user_to_account
    user.account = account
  end
end

# app/controllers/signup_controller.rb

class SignupsController < ApplicationController
  def new
    @signup = Signup.new
  end
  def create
    @signup = Signup.new(params[:signup])
      
    if @signup.save
      flash[:notice] = 'Thank you for signing up!'
      redirect_to root_url
    else
      render :action => "new"
    end
  end
end

# app/views/signups/new.html.erb

<h1>Signup!</h1>
  
<%= form_for(@signup) do |f| %>
  <%= f.error_messages %>
    
  <p>
    <%= f.label :account_subdomain %><br />
    <%= f.text_field :account_subdomain %>
  </p>
  
  <p>
    <%= f.label :user_email %><br />
    <%= f.text_field :user_email %>
  </p>
  
  <p>
    <%= f.label :user_password %><br />
    <%= f.text_field :user_password %>
  </p>
  
  <p>
    <%= f.submit "Create" %>
  </p>
<% end %>
