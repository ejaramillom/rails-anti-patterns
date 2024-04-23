# authentication and authorization: clearance and authlogic gems

class class WidgetsController < ApplicationController
  before_filter :authenticate # this comes from setting up gem clearance
  def index
    @widgets = Widget.all
  end
end