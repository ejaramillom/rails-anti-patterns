# make use of composition
# There is a difference between include and extend in this Order object model:
# include puts the module’s methods on the calling class as instance methods, and
# extend makes them into class methods.
# bad

# app/models/bank_account.rb
# app/models/order.rb
class Order < ActiveRecord::Base
  def self.find_purchased
  # ...
  end
  
  def self.find_waiting_for_review
  # ...
  end
  
  def self.find_waiting_for_sign_off
  # ...
  end
  
  def self.find_waiting_for_sign_off
  # ...
  end
  
  def self.advanced_search(fields, options = {})
  # ...
  end
  
  def self.simple_search(terms)
  # ...
  end
  
  def to_xml
  # ...
  end
  
  def to_json
  # ...
  end
end

# good

# app/models/order.rb
class Order < ActiveRecord::Base
  extend OrderStateFinders
  extend OrderSearchers
  include OrderExporters
end

# lib/order_state_finders.rb
module OrderStateFinders
  def find_purchased
  # ...
  end
  
  def find_waiting_for_review
  # ...
  end
  
  def find_waiting_for_sign_off
  # ...
  end
end
  