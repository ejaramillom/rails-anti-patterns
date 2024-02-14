# avoid calling beyond a neighbor
# bad

@invoice.customer.name
@invoice.customer.address.street
@invoice.customer.address.city
@invoice.customer.address.state
@invoice.customer.address.zip

# good

class Address < ActiveRecord::Base
  belongs_to :customer
end

class Customer < ActiveRecord::Base
  has_one :address
  has_many :invoices
  delegate :street, :city, :state, :zip_code, :to => :address
end

class Invoice < ActiveRecord::Base
  belongs_to :customer
  
  delegate :name,
           :street,
           :city,
           :state,
           :zip_code,
           :to => :customer,
           :prefix => true
end

@invoice.customer_name
@invoice.customer_street