# two identical classes with similar methods

# bad

class Car << ActiveRecord::Base
  validates :direction, presence: true
  validates :speed, presence: true
  
  def turn(new_direction)
    self.direction = new_direction
  end
  
  def brake
    self.speed = 0
  end
  
  def accelerate
    self.speed = speed + 10
  end
  # Other, car-related activities...
end

class Bicycle << ActiveRecord::Base
  validates :direction, presence: true
  validates :speed, presence: true
  
  def turn(new_direction)
    self.direction = new_direction
  end
  
  def brake
    self.speed = 0
  end
  
  def accelerate
    self.speed = speed + 10
  end
  # Other, bike-related activities...
end

# better

# lib/drivable.rb
module Drivable
  extend ActiveSupport::Concern

  included do
    validates :direction, presence: true
    validates :speed, presence: true
  end  
  
  def turn(new_direction)
    self.direction = new_direction
  end
  
  def brake
    self.speed = 0
  end
  
  def accelerate
    self.speed = speed + 10
  end
end

class Car << ActiveRecord::Base
  include Drivable
  # Other, car-related activities...
end

class Bicycle << ActiveRecord::Base
  include Drivable
  # Other, bike-related activities...
end

#config/initializers/requires.rb
Dir[File.join(Rails.root, 'lib', '*.rb')].each do |module|
  require module
end