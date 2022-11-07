class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by_email(params[:email])
    # 認証済みかつ有効ではない
    if user && !user.activated? && user.is_activated?(params[:id])
      user.activate
      log_in(user)
      flash[:success] = "Account activated!"
      redirect_to(user)
    else
      flash[:danger] = "Invalid activation link"
      redirect_to(root_url)
    end
  end
end
