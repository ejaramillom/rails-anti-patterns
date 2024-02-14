# bad

class Article < ApplicationRecord
  belongs_to :state
  belongs_to :category
  
  validates :state_id, presence: true
  validates :category_id, presence: true
end

class State < ApplicationRecord
  has_many :articles
end

class Category < ApplicationRecord
  has_many :articles
end