class StaticPagesController < ApplicationController
  def home
    current_user = get_current_user_or_nil
    unless current_user.nil?
      @micropost = current_user.microposts.build if logged_in?
      @feed_items = current_user.get_microposts.paginate(page: params[:page])
    end
  end

  def help
  end

  def about    
  end

  def contact
  end
end
