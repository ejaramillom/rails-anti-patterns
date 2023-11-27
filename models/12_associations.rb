# keep finders in their correct model
# bad

class UsersController < ApplicationController
  def index
    @user = User.find(params[:id])
    @recent_active_memberships = @user.find_recent_active_memberships
  end
end

class User < ActiveRecord::Base
  has_many :memberships

  def find_recent_active_memberships
    memberships.where(active: true)
               .limit(5)
               .order('last_active_on DESC')
  end
end

# good (use associations)

class User < ActiveRecord::Base
  has_many :memberships

  def find_recent_active_memberships
    memberships.find_recently_active
  end
end

class Membership < ActiveRecord::Base
  belongs_to :user

  def self.find_recently_active
    where(active: true).limit(5).order('last_active_on DESC')
  end
end
