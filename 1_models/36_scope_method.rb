# The scope method defines class methods on your model that can be chained together and combined into one SQL query. A scope can be defined by a hash of options that should be merged into the find call or by a lambda that can take arguments and return such a hash.

# When you call a scope , you get back an ActiveRecord::Relation object, which walks and talks just like the array you would have gotten back from find . The crucial difference is that the database lookup is lazy-evaluated—that is, it’s not triggered until you actually try to access the records in the array

# Scopes are an implementation of the Virtual Proxy design pattern, which means they act as a proxy for the result set returned from find . However, they do not initialize that result set until an actual record is accessed.

# bad

class RemoteProcess < ApplicationRecord
  def self.find_top_running_processes(limit = 5)
    find(:all,
      :conditions => "state = 'Running'",
      :order => "percent_cpu desc",
      :limit => limit)
  end
  
  def self.find_top_running_system_processes(limit = 5)
    find(:all,
      :conditions => "state = 'Running' and
      (owner in ('root', 'mysql')",
      :order => "percent_cpu desc",
      :limit => limit)
  end
end

# good

class RemoteProcess < ApplicationRecord
  scope :running, where(state: 'Running')
  scope :system, where(owner: ['root', 'mysql'])
  scope :sorted, order("percent_cpu desc")
  scope :top, ->(amount) { limit(amount) }
end

RemoteProcess.running.sorted.top(10)
RemoteProcess.running.system.sorted.top(5)

# recommended

class RemoteProcess < ApplicationRecord
  def self.running
    where(:state => 'Running')
  end
  
  def self.system
    where(:owner => ['root', 'mysql'])
  end
  
  def self.sorted
    order("percent_cpu desc")
  end
  
  def self.top(l)
    limit(l)
  end
end

# avoid law of demeter violations smells

class RemoteProcess < ApplicationRecord
  scope :running, where(:state => 'Running')
  scope :system, where(:owner => ['root', 'mysql'])
  scope :sorted, order("percent_cpu desc")
  scope :top, ->(amount) { limit(amount) }
    
  def self.find_top_running_processes(limit = 5)
    running.sorted.top(limit)
  end
  
  def self.find_top_running_system_processes(limit = 5)
    running.system.sorted.top(limit)
  end
end 

# bad

class Song < ApplicationRecord
  def self.search(title, artist, genre, published, order, limit, page)
    condition_values = { :title => "%#{title}%", :artist => "%#{artist}%", :genre => "%#{genre}%"}
      
    case order
    when "name":
      order_clause = "name DESC"
    when "length": 
      order_clause = "duration ASC"
    when "genre": 
      order_clause = "genre DESC"
    else
      order_clause = "album DESC"
    end
    
    joins = []
    conditions = []
    conditions << "(title LIKE ':title')" unless title.blank?
    conditions << "(artist LIKE ':artist')" unless artist.blank?
    conditions << "(genre LIKE ':genre')" unless genre.blank?
   
    unless published.blank?
      conditions << "(published_on == :true OR published_on IS NOT NULL)"
    end
    
  find_opts = { 
    :conditions => [conditions.join(" AND "),  condition_values],  
    :joins  => joins.join(' '),  
    :limit  => limit,
    :order  => order_clause }
  page = 1 if page.blank?
  paginate(:all, find_opts.merge(:page => page,  :per_page => 25))
end

# good

  class Song < ApplicationRecord
    def self.top(number)
      limit(number)
    end
    
    def self.matching(column, value)
      where(["#{column} like ?", "%#{value}%"])
    end
    
    def self.published
      where("published_on is not null")
    end
    
    def self.order(col)
      sql = case col
      when "name":
        "name desc"
      when "length": 
        "duration asc"
      when "genre": 
        "genre desc"
      else 
        "album desc"
      end
      
      order(sql)
    end
    
    def self.search(title, artist, genre, published)
      finder = matching(:title, title)
      finder = finder.matching(:artist, artist)
      finder = finder.matching(:genre, genre)
      finder = finder.published unless published.blank?
      
      return finder
    end
  end
  
  Song.search("fool", "billy", "rock", true).
        order("length").
        top(10).
        paginate(:page => 1)
