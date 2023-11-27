# do not put logic in views or controller. Push All find() Calls into Finders on the Model
# bad

<html>
  <body>
    <ul>
      <% User.find(:order => "last_name").each do |user| -%>
        <li><%= user.last_name %> <%= user.first_name %></li>
      <% end %>
    </ul>
  </body>
</html>

# good

class User < ActiveRecord::Base
  scope :ordered, order("last_name")
end


class UsersController < ApplicationController
  def index
    @users = User.ordered
  end
end

