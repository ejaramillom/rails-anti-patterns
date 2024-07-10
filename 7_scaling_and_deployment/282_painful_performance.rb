# don't do in ruby what you can do in SQL

# The two most common causes for this are making a simple mistake, such as misunderstanding the Active Record API, and laziness.

@article.comments.count
@article.comments.length
@article.comments.size

# All three of these methods will return the same correct number. However, each of them performs a dramatically different operation.

# @article.comments.count executes an SQL count statement to find the number of items in the relationship. @article.comments.length is not defined on Active Record relationships, and therefore it falls through and causes all the records in the relationship to be loaded and causes length to be called on the resulting collection. @article.comments.size calls length on the collection of items in the relationship if it has already been loaded; otherwise, it calls count. Each of the three different methods has a purpose, but unfamiliarity with the API or simple forgetfulness might cause a developer to call length. This could potentially load thousands of objects into memory and cause a very slow action.

# bad (sorting in ruby)

@account = Account.find(3)
@users = @account.users.sort { |a,b| a.name.downcase <=>
b.name.downcase }.first(5)

# good (sort in SQL)

SELECT * FROM users 
WHERE account_id = '3' 
ORDER BY LCASE(name)
LIMIT 5

@users = @account.users.order('LCASE(name)').limit(5)

# terrible (flatten partial searches in ruby)

class User < ActiveRecord::Base
  has_many :comments
  has_many :articles, :through => :comments
  
  def collaborators
    articles.collect { |a| a.users }.flatten.uniq.reject {|u| u == self }
  end
end

# Note that oftentimes a good indicator that Ruby is being used for something that SQL should be used for is that it contains calls to the flatten method. The preceding collaborators method can be rewritten using SQL (with Active Record finders):

# good (fix queries in SQL)

class User < ActiveRecord::Base
  has_many :comments
  has_many :articles, :through => :comments
  
  def collaborators
    User.select("DISTINCT users.*").
         joins(comments: [:user, {article: :comments}]).
         where(["articles.id in ? AND users.id != ?",
                 self.article_ids, self.id])
  end
end

SELECT DISTINCT users.* FROM users
  INNER JOIN comments
    ON comments.user_id = users.id
  INNER JOIN users users_comments
    ON users_comments.id = comments.user_id
  INNER JOIN articles
    ON articles.id = comments.article_id
  INNER JOIN comments comments_articles
    ON comments_articles.article_id = articles.id
  WHERE (articles.id in (1) AND users.id != 1)

# good (move processing into background jobs)

# a list of possible pain points in a normal request/response cycle

# generating reports
# updating lots of related data in an associated object based on user action
# updating various caches
# communicating with slower external resources
# sending email

# There are a number of popular queuing systems for Rails. Two of the most popular and well supported are delayed_job (or DJ; http://github.com/tobi/delayed_job) and Resque (http://github.com/defunkt/resque). Both of these are libraries for creating background jobs, placing jobs in queues, and processing those queues. Resque is backed by a Redis datastore, and delayed_job is SQL backed.

class SalesReport < Struct.new(:user)
def perform
report = generate_report
Mailer.sales_report(user, report).deliver
end
private
def generate_report
FasterCSV.generate do |csv|
csv << CSV_HEADERS
Sales.find_each do |sale|
csv << sale.to_a
end
end
end
end