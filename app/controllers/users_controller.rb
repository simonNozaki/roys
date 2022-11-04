class UsersController < ApplicationController
  # フィルタアクション、コントローラのメソッド呼び出し前に実行できる
  before_action(:redirect_if_not_logged_in, { only: [:edit, :update] })
  before_action(:redirect_if_not_authenticated, { only: [:edit, :update] })
  # TODO: debugしなくなったら消す
  attr_reader :user, :current_user

  def show
    @user = User.find(params[:id])
    # debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(get_validated_user_params)
    if @user.save
      log_in(@user)
      # redirect_to user_url(@user) と等価
      flash[:success] = "Welcome to the Roys!"
      redirect_to @user
    else
      render "new"
    end
  end

  def edit
    # redirect_if_not_authenticatedで@userを初期化しているので何もしない
  end

  def update
    if @user.update(get_validated_user_params)
      flash[:success] = "Profile updated"
      redirect_to(@user)
    else
      render('edit')
    end
  end

  private
    def get_validated_user_params
      params
        .require(:user)
        .permit(
          :name,
          :email,
          :password,
          :password_confirmation
        )
    end

    def redirect_if_not_logged_in
      if not logged_in?
        flash[:danger] = "Please log in."
        redirect_to(login_url)
      end
    end

    # 認証中のユーザでなければ強制リダイレクト
    def redirect_if_not_authenticated
      @user = User.find(params[:id])
      current_user_or_nil = get_current_user_or_nil
      if get_current_user_or_nil != @user
        redirect_to(root_url)
      end
    end
end
