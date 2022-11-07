class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    # nil-safe operator https://mitrev.net/ruby/2015/11/13/the-operator-in-ruby/
    unless @user&.authenticate(params[:session][:password])
      flash.now[:danger] = 'Invalid email/password combination'
      return render 'new'
    end

    if @user.activated?
      log_in(@user)
      params[:session][:remember_me] == REMEMBER_ME_CHECK_ON ? remember(@user) : forget(@user)
      redirect_back_or(@user)
    else
      flash[:warning] = <<-EOS
Account not activated. Check your email for the activation link.
      EOS
      redirect_to(root_url)
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to(root_url)
  end

  private
    REMEMBER_ME_CHECK_ON = '1'
end
