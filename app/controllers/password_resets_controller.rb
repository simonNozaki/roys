class PasswordResetsController < ApplicationController
  before_action(-> {
    get_user_by_email(params[:email])
  }, { only: [:edit, :update] })
  before_action(:redirect_if_not_authenticated, { only: [:edit, :update] })
  before_action(:redirect_if_expired, { only: [:edit, :update] })

  def new
  end

  def create
    @user = User.find_by_email(params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instruction"
      redirect_to(root_url)
    else
      flash[:danger] = "Email address not found. Please be sure your email is correct."
      render('new')
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      return render('edit')
    end
    if @user.update(get_validated_user_params)
      log_in(@user)
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      return redirect_to(@user)
    end
    render('edit')
  end

  private
  def get_validated_user_params
    params
      .require(:user)
      .permit(
        :password,
        :password_confirmation
      )
  end

    # @param [String] email
    def get_user_by_email(email)
      @user = User.find_by_email(email)
    end

    # 認証されていない場合ホームにリダイレクト
    def redirect_if_not_authenticated
      unless @user&.activated? && @user&.reset?(params[:id])
        redirect_to(root_url)
      end
    end

  def redirect_if_expired
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to(new_password_reset_url)
    end
  end
end
