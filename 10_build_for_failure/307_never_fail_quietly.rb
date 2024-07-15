# good (make use of bang method to return error when validation fails)
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors

class Ticket < ActiveRecord::Base
  def self.bulk_change_owner(user)
    transaction do
      all.each do |ticket|
        ticket.owner = user
        ticket.save!
      end
    end
  end
end

# bad (rescue nil)

class Order < ActiveRecord::Base
  def place!
    fh_order = send_to_fulfillment_house!
    self.fulfillment_house_order_number = fh_order.number
    save!
    return fh_order.number
  end
end
      
order_number = order.place! rescue nil
if order_number.nil?
  flash[:error] = "Unable to reach Fulfillment House." +
                  " Please try again."
end

# The code makes use of an inline rescue statement to force the returned order number to nil if an exception was raised  

# the code not only swallows any network errors that occurred during the send_to_fulfillment_house! call, it also cancels any validation errors that happened during the save! cal  

# good (send errors to new relic or any logger tool)

class Tweet < ActiveRecord::Base
  before_create :send_tweet
  
  def send_tweet
    twitter_client.update(body)
    rescue *TWITTER_EXCEPTIONS => e
    HoptoadNotifier.notify e
    errors.add_to_base("Could not contact Twitter.")
  end
end
  