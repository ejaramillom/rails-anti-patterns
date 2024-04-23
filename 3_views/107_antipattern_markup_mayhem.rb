# semantic markup

# • Every element in the page that wraps specific content should have a class or id attribute applied to it that identifies that content.
# • The right tags should be used for the right content.
# • Styling should be done at the CSS level and never on the element directly.

# terrible

<div>
  <div>
    <span style="font-size: 2em;">
      I love kittens!
    </span>
  </div>
  <div>
    I love kittens because theyre
      <span style="font-style: italic">
        soft and fluffy!
      </span>
  </div>
</div>

# bad

<div id="posts">
  <div id="post_1" class="post">
    <h2>
      I love kittens!
    </h2>
    <div class="body">
      I love kittens because theyre
      <em>
        soft and fluffy!
      </em>
    </div>
  </div>
</div>

# bad example 

<div class="post" id="post_<%= @post.id %>">
  <h2 class="title">Title</h2>
  <div class="body">
    Lorem ipsum dolor sit amet, consectetur...
  </div>
  <ol class="comments">
    <% @post.comments.each do |comment| %>
      <li class="comment" id="comment_<%= comment.id %>">
        <%= comment.body %>
      </li>
    <% end %>
  </ol>
</div>

# better

<%= div_for @post do %>
  <h2 class="title">Title</h2>
  <div class="body">
    Lorem ipsum dolor sit amet, consectetur...
  </div>
  <ol class="comments">
    <% @post.comments.each do |comment| %>
      <%= content_tag_for :li, comment do %>
        <%= comment.body %>
      <% end %>
    <% end %>
  </ol>
<% end %>