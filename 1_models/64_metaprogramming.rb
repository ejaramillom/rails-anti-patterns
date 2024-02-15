# bad

class PurchaseTest < Test::Unit::TestCase
  context "Given some Purchases of each status" do
    setup do
      %w(in_progress submitted approved
      shipped received canceled).each do |s|
      Factory(:purchase, :status => s)
    end
      
  end
  context "Purchase.all_in_progress" do
    setup { @purchases = Purchase.all_in_progress }
      should "not be empty" do
      assert !@purchases.empty?
    end
    
    should "return only in progress purchases" do
      @purchases.each do |purchase|
        assert purchase.in_progress?
      end
    end
    
    should "return all in progress purchases" do
      expected = Purchase.all.select(&:in_progress?)
        assert_same_elements expected, @purchases
      end
    end
  end
end

# class defined to fulfill the test requirements 

class Purchase < ApplicationRecord
  validates_presence_of :status
  validates :status, inclusion: { in: %w[in_progress submitted approved shipped received canceled] }
    
  # Status Finders
  def self.all_in_progress
    where(:status => "in_progress")
  end
  
  def self.all_submitted
    where(:status => "submitted")
  end
  
  def self.all_approved
    where(:status => "approved")
  end
  
  def self.all_shipped
    where(:status => "shipped")
  end
  
  def self.all_received
    where(:status => "received")
  end
  
  def self.all_canceled
    where(:status => "canceled")
  end
  
  # Status Accessors
  def in_progress?
    status == "in_progress"
  end
  
  def submitted?
    status == "submitted"
  end
  
  def approved?
    status == "approved"
  end
  
  def shipped?
    status == "shipped"
  end
  
  def received?
    status == "received"
  end
  
  def canceled?
    status == "canceled"
  end
end

# better

class Purchase < ApplicationRecord
  STATUSES = %w(in_progress submitted approved shipped received)
  
  validates_presence_of :status
  validates :status, inclusion: { in: STATUSES }
  
  # Status Finders
  
  class << self
    STATUSES.each do |status_name|
      define_method "all_#{status_name}"
        where(:status => status_name)
      end
    end
  end

  # Status Accessors
  STATUSES.each do |status_name|
    define_method "#{status_name}?"
      status == status_name
    end
  end
end

# best

# lib/extensions/statuses.rb
class ApplicationRecord
  def self.has_statuses(*status_names)
    validates :status,
    presence: true,
    inclusion: { in: status_names }
      
    # Status Finders
    status_names.each do |status_name|
      scope "all_#{status_name}", where(status: status_name)
    end
    
    # Status Accessors
    status_names.each do |status_name|
      define_method "#{status_name}?" do
        status == status_name
      end
    end
  end
end

class Purchase < ApplicationRecord
  has_statuses :in_progress, :submitted, :approved, :shipped, :received, :partially_shipped, :fully_shipped, :canceled

  scope :all_not_shipped, -> { where(status: ["partially_shipped",  "fully_shipped"]) }
  
  def not_shipped?
    !(partially_shipped? or fully_shipped?)
  end
end
