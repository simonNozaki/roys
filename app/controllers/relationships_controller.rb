class RelationshipsController < ApplicationController
  before_action(:redirect_if_not_logged_in)

  def create
    @user = User.find(params[:followed_id])
    get_current_user_or_nil.follow(@user)
    respond_to do |format|
      format.html { redirect_to(@user) }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    get_current_user_or_nil.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to(@user) }
      format.js
    end
  end
end
