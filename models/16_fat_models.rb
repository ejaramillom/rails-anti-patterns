# Delegate Responsibility to New Classes
# bad

class Order < ActiveRecord::Base
  # more methods related to orders
  # ...

  def to_xml
    # ...
  end

  def to_json(*_args)
    # ...
  end

  def to_csv
    # ...
  end

  def to_pdf
    # ...
  end
end

# good

# app/models/order.rb
class Order < ActiveRecord::Base
  delegate :to_xml, :to_json, :to_csv, :to_pdf, to: :converter

  def converter
    OrderConverter.new(self)
  end
end

# app/models/order_converter.rb
class OrderConverter
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def to_xml
    # ...
  end

  def to_json(*_args)
    # ...
  end

  def to_csv
    # ...
  end

  def to_pdf
    # ...
  end
end

@order.to_pdf
