class ApplicationController < ActionController::Base
  include SessionsHelper

  private
    def redirect_if_not_logged_in
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to(login_url)
      end
    end
end
