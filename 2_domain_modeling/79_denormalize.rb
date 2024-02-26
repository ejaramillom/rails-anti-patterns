# bad

# bad 

# Very often, there is quite a bit of functionality associated with these types of models (states, categories, and so on) and, therefore, it’s not desirable to allow end users or even administrators to add or remove available states in the database. For example, if the article publication workflow changes and a new state needs to be added, it’s unlikely that an administrator can simply add the state to the database and have everything as desired. Therefore, when you’re building lean, agile applications, it doesn’t make sense to spend time and effort programming an administrative interface for states. And if there isn’t a user interface for adding and removing states, then it simply isn’t worthwhile to store the states in the database. Instead, you can just store the states in the code itself.

class Article < ApplicationRecord
  belongs_to :state
  belongs_to :category
  
  validates :state_id, presence: true
  validates :category_id, presence: true
end

class State < ApplicationRecord
  has_many :articles
  validates :name, presence: true
  
  class << self # to replace @article.state = State.find_by_name("published")
    all.each do |state|
      define_method "#{state}" do
        first(conditions: { name: state })
      end
    end
  end
end

class Category < ApplicationRecord
  has_many :articles
end

# good 

class Article < ActiveRecord::Base
  STATES = %w(draft review published archived)
  CATEGORIES = %w(tips faqs misc)
  
  validates :state, inclusion: { in: STATES }
  validates :category, inclusion: { in: CATEGORIES }
  
  STATES.each do |state|
    define_method "#{state}?" do
     self.state == state
    end
  end

  CATEGORIES.each do |category|
    define_method "#{category}?" do
      self.category == category
    end
  end

  class << self
    STATES.each do |state|
      define_method "#{state}" do
        state
      end
    end

    CATEGORIES.each do |category|
      define_method "#{category}" do
        category
      end
    end
  end
end

# Never build beyond the application requirements at the time you are writing the code.
# If you do not have concrete requirements, don’t write any code.
# Don’t jump to a model prematurely; there are often simple ways, such as using Booleans and denormalization, to avoid using adding additional models.
# If there is no user interface for adding, removing, or managing data, there is no need for a model. A denormalized column populated by a hash or array of possible values is fine.