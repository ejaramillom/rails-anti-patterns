# add indexes in DB

# Primary Keys

# Most SQL databases with the concept of a primary key will automatically create an index on the primary key column when it exists. In Rails, this is typically the id column in a table. Fortunately, because Rails tells the database that it’s a primary key, you’ll get the index for free—that is, created by the database. This is very important for a view for the show action, like /users/1, for example. The request comes in, and the query to “find user with id equal to 1” occurs very quickly because the users.id column is indexed.

# Foreign Keys

# Given the following User model, there will be a user_id column in the comments table, and the Comment model will use this column to determine the user that it belongs to:

class User < ActiveRecord::Base
  has_many :comments
end

# You should have an index on every foreign key column. When you make a page like /users/1/comments, two things need to happen. First, you look up the user with id equal to 1. If you’ve indexed primary keys, this index will be hit. Second, you want to find all comments that belong to this user. If you’ve indexed comments.user_id, this index will be used as well.

# Because one of the biggest issues with indexes is remembering to add them, you might consider enforcing a code policy of only naming actual foreign key columns ending in _id. This will act as a hint that such a column needs to be indexed.

# Columns Used in Polymorphic Conditional Joins

# The following models set up a polymorphic relationship between comments and tags. Other models in this application can also have tags, and this is why they are polymorphic:

class Tag < ActiveRecord::Base
  has_many :taggings
end

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
end

class Comment < ActiveRecord::Base
  has_many :taggings, :as => :taggable
end

# add indexes in polymorphic relations because it is a foreign key association

class AddindexesToAllPolymorphicTables < ActiveRecord::Migration
  def self.up
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end
  
  def self.down
    remove_index :taggings, :column => [:taggable_id, :taggable_type]
    remove_index :taggings, :tag_id
  end
end

# seek  missing indexes

# There are several Rails plugins you can use tools to identify missing indexes. The simplest of them is Limerick Rake (http://github.com/thoughtbot/limerick_rake), which provides a rake task db:indexes:missing. When run on your application, this task examines your database and identifies obvious missing indexes, primarily missing foreign key indexes.

# You can also turn on MySQL slow query logging, which is described at http://dev.mysql.com/doc/refman/5.1/en/slow-query-log.html, and its sidekick log-queries-not-using-indexes. If you add the following to your MySQL configuration, your MySQL will take note of queries that take a long time or do not use any indexes

# This log will serve as an important indicator of potential places for missing indexes. There are also two Rails plugins that will print out EXPLAIN statements of every query used to render a page to the page itself. These can assist in identifying issues. The two plugins are Rails Footnotes (http://github.com/josevalim/rails-footnotes) and QueryReviewer (http://github.com/dsboulder/query_reviewer).

# Finally, New Relic RPM (www.newrelic.com) is a Rails plugin that monitors an application’s performance and sends the information to the New Relic RPM service for analysis and monitoring. You can then log into the service and drill down into the various layers of the MVC stack to see how much time is spent where. For diagnosing performance problems, including slow queries, New Relic RPM is an invaluable tool. 

# bad (reassess domain model)

class State < ActiveRecord::Base
  validates :name, :unique => true
end

class User < ActiveRecord::Base
end

class Category < ActiveRecord::Base
  validates :category, :unique => true
end

class Article < ActiveRecord::Base
  belongs_to :state
  belongs_to :categories
  belongs_to :user
end

# articles query

SELECT * from articles
LEFT OUTER JOIN states ON articles.state_id=states.id
LEFT OUTER JOIN categories ON articles.category_id=categories.id
WHERE articles.category_id = categories.id
AND states.name = 'published'
AND categories.name = 'hiking'
AND articles.user_id = 123

Article.includes([:state, :category]).
        where("states.name" => "published",
              "categories.name" => "hiking",
              "articles.user_id" => current_user)

# good (change your queries and rewrite your models, avoid the joins)

SELECT * from articles
WHERE state_id = 150
AND category_id = 50
AND user_id = 123

# articles query

published_state = State.find_by_name('published')
hiking_category = Category.find_by_name('hiking')
Article.where("state_id" => published_state,
      "category_id" => hiking_category,
      "user_id" => current_user)

# N + 1 problem

<table>
  <tr>
    <th>Title</th>
    <th>User</th>
    <th>State</th>
    <th>Category</th>
  </tr>
  <% @articles.each do |article| %>
    <% content_tag_for :tr, article do %>
      <td><%= article.title %></td>
      <td><%= article.user.name %></td>
      <td><%= article.state.name %></td>
      <td><%= article.category.name %></td>
    <% end %>
  <% end %>
</table>

# For each new state, category, and user on articles, a new query will be performed to look up and load the object. This could potentially be many queries and could cause this page to load too slowly.

# You can solve this problem by using a strategy called eager loading that’s built into Active Record. To do this, you change your query to retrieve the articles to use the includes scope:

Article.includes([:state, :category, :user])

# learn to love denormalized datasets (eliminate unnecessary models)

class Article < ActiveRecord::Base
  STATES = %w(draft review published archived)
  CATEGORIES = %w(tips faqs misc hiking)
  validates :state, :inclusion => {:in => STATES}
  validates :category, :inclusion => {:in => CATEGORIES}
end

# the new query pulls from a single table and requires no subsequent queries

Article.where("state" => "published",
              "category" => "hiking",
              "user_id" => current_user)

# idiomatically

current_user.articles.find_all_by_state_and_category("published", "hiking")