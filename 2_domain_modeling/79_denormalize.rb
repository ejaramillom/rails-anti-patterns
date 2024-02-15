# bad

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