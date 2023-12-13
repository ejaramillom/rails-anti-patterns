# bad

class Account < ActiveRecord::Base
  def create_account!(account_params, user_params)
    transaction do
      account = Account.create!(account_params)
      first_user = User.new(user_params)
      first_user.admin = true
      first_user.save!
      users << first_user
      account.save!
      Mailer.deliver_confirmation(first_user)
      return account
    end
  end
end

# good

class Account < ActiveRecord::Base
  accepts_nested_attributes_for :users

  before_create :make_admin_user
  after_create :send_confirmation_email

  private

  def make_admin_user
    users.first.admin = true
  end

  def send_confirmation_email
    Mailer.confirmation(users.first).deliver
  end
end

class AccountsController < ApplicationController
  def create
    @account = Account.new params[:account]

    if @account.save
      flash[:notice] = 'Your account was successfully created.'
      redirect_to account_url(@account)
    else
      render action: :new
    end
  end
end
