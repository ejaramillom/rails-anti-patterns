# two identical classes with similar methods

# bad

class Car << ApplicationRecord
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

class Bicycle << ApplicationRecord
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

class Car << ApplicationRecord
  include Drivable
  # Other, car-related activities...
end

class Bicycle << ApplicationRecord
  include Drivable
  # Other, bike-related activities...
end

#config/initializers/requires.rb
Dir[File.join(Rails.root, 'lib', '*.rb')].each do |module|
  require module
end

# plugin

./script/rails generate plugin drivable

# http://guides.rubyonrails.org/plugins.html.

# lib/drivable/active_record_extensions.rb
module Drivable
  module ActiveRecordExtensions
    module ClassMethods
      def drivable
        validates_presence_of :direction, :speed
        
        include ActiveRecordExtensions::InstanceMethods
      end
    end
  
    module InstanceMethods
      def turn(new_direction)
        self.direction = new_direction
      end
      
      def brake
        self.speed = 0
      end
      
      def accelerate
        self.speed = [speed + 10, 100].min
      end
    end
  end
end

# lib/drivable.rb
require "drivable/active_record_extensions"
  
class ApplicationRecord
  extend Drivable::ActiveRecordExtensions::ClassMethods
end
  
# init.rb
require File.join(File.dirname(__FILE__), "lib", "drivable")