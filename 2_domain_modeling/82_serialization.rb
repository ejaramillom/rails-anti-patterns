# a registration form where the user is asked to select the one or more ways he or she heard about the organization. A user who selects Other should fill in the “other” text input field. This is a fairly common interface, and you can model it in a few different ways, using Active Record models

# bad
# there is no interface to add referral values to the database

class User < ActiveRecord::Base
  has_many :referral_types
end

class Referral < ActiveRecord::Base
  has_and_belongs_to_many :users
end

# bad

class User < ActiveRecord::Base
 has_many :referral_types
end

class Referral < ActiveRecord::Base
  VALUES = %w[Newsletter School Web Partners/Events Media Other]
  
  validates :value, inclusion: { in: VALUES }
  belongs_to :user
end

# good: serializers

class User < ActiveRecord::Base
  HEARD_THROUGH_VALUES = %w[Newsletter School Web Partners/Events Media Other]
  
  serialize :heard_through, Hash
end

# Now each of the check boxes will be either checked or unchecked, resulting in a Hash of the checked values being submitted. The view code that makes this possible looks as follows:

<%= fields_for :heard_through, (form.object.heard_through || {} ) do |heard_through_fields| -%>
  <% User::HEARD_THROUGH_VALUES.each do |heard_through_val| -%>
    <%= heard_through_fields.check_box "field" -%>
    <%= heard_through_fields.label :heard_through, heard_through_val -%>
  <% end -%>
<% end -%>

# the problem with serializers is that you lose the ability to .find and use these kinds of convention methods over the data in the serialization

# Notices represent the exceptions sent in from other applications
class Notice < ActiveRecord::Base
  serialize :request, Hash
  serialize :session, Hash
  serialize :environment, Hash
  serialize :backtrace, Array

  before_validation :extract_backtrace_info, on: :create
  before_validation :extract_request_info, on: :create
  before_validation :extract_environment_info, on: :create

  private
  
  def extract_backtrace_info
    unless backtrace.blank?
      self.file, self.line_number = backtrace.first.split(':')
    end
  end

  def extract_request_info
    unless request.blank? or request[:params].nil?
      self.controller = request[:params][:controller]
      self.action = request[:params][:action]
    end
  end
  
  def extract_environment_info
    unless environment.blank?
      self.rails_env = environment['RAILS_ENV']
    end
  end
end

# As previously mentioned, the primary downside of serialization of data is that you lose the ability to search through the serialized data.
