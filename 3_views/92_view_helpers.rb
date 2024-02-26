# bad

<%= form_for :user,
    url: user_path(@user),
    html: { method: :put } do |form| %>
<% end %>    

# good

<%= form_for @user do |form| %>
<% end %>

# bad: manual rendering

# posts/index.html.erb
<% @posts.each do |post| %>
  <h2><%= post.title %></h2>
  <%= format_content post.body %>
  <p>
  <%= link_to 'Email author', mail_to(post.user.email) %>
  </p>
<% end %>

# good: partials

# posts/index.html.erb -->
<%= render @posts %>

<!-- posts/_post.erb -->
<h2><%= post.title %></h2>
<%= format_content post.body %>
<p>
<%= link_to 'Email author', mail_to(post.user.email) %>
</p>

# An additional view helper provided by Rails but often overlooked by developers is the content_for helper. This helper is a powerful tool that can introduce additional organization into your view files without the need for custom methods. You use the content_for method to insert content into various sections of a layout. For example, consider the following view layout:

<html>
  <body>
    <ul class="nav">
      <li><%= link_to "Home", root_url %></li>
      <li><%= link_to "Maps", maps_url %></li>
      <%= yield :nav %>
    </ul>
    <div class="main">
      <%= yield %>
    </div>
  </body>
</html>

# The yield method in this application is a companion to the content_for method. Envision a website where the content of the nav can change, depending on the view being rendered to the visitor. An accompanying view would call content_for and give it the content for the nav . Any view content not handed to a specific named section is given to the default, unnamed yield . For example, a view that populates the nav and the main section of the view would appear as follows:

<% content_for :nav do %>
  <li>
    <%= link_to "Your Account", account_url %>
  </li>
  <li>
    <%= link_to "Your Maps", user_maps_url(current_user) %>
  </li>
<% end %>
This is the content for the main section of the website. Go <%=link_to "Home", root_url %>

# When this view is rendered, the call will render the additional content for the nav to yield :nav .
# Many developers who are not familiar with content_for will accomplish this functionality by assigning the content for various sections to instance variables, either in the controller or the view itself, using the render_to_string or render :inline methods.

# conditional rendering

<% if content_for?(:sidebar) %>
  <div class="sidebar">
    <%= yield :sidebar %>
  </div>
<% end %>
            