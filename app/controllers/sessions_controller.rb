class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # nil-safe operator https://mitrev.net/ruby/2015/11/13/the-operator-in-ruby/
    if user&.authenticate(params[:session][:password])
      log_in(user)
      redirect_to(user)
    else
      # 次のリクエストが来るとnilになる
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out()
    redirect_to(root_url)
  end
end