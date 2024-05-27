# bad (multiple conditionals for nested objects and attributes)

class MessagesController < ApplicationController
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @messages = @user.messages
    else
      @messages = Message.all
    end
  end
end

resources :messages
resources :users do
  resources :messages
end

<h1>Messages<% if @user %> for <%= @user.name %><% end %></h1>
<ul>
  <% @messages.each do |message| %>
    <%= content_tag_for :li, @message do %>
    <span class="subject"><%= message.subject %></span>
    <% if !@user %>
      <span class="poster">Posted by <%= message.user.name %></span>
    <% end %>
      <span class="body"><%= message.body %></span>
    <% end %>
  <% end %>
</ul>

# better (use separate controllers for each nesting)

controllers/messages_controller.rb
controllers/users/messages_controller.rb

resources :messages
resources :users do
  resources :messages, :controller => ‘users/messages’
end

# controllers/messages_controller.rb
class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end
end

# controllers/users/messages_controller.rb
class MessagesController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @messages = @user.messages
  end
end

# <!-- views/messages/index.html.erb -->

<h1>Messages</h1>
<ul>
  <% @messages.each do |message| %>
    <%= content_tag_for :li, @message do %>
      <span class="subject"><%= message.subject %></span>
      <span class="poster">Posted by <%= message.user.name %></span>
      <span class="body"><%= message.body %></span>
    <% end %>
  <% end %>
</ul>
          
# <!-- views/users/messages/index.html.erb -->
        
<h1>Messages for <%= @user.name %></h1>
<ul>
  <% @messages.each do |message| %>
    <%= content_tag_for :li, @message do %>
      <span class="subject"><%= message.subject %></span>
      <span class="body"><%= message.body %></span>
    <% end %>
  <% end %>
</ul>
