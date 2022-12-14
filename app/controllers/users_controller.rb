class UsersController < ApplicationController
  # フィルタアクション、コントローラのメソッド呼び出し前に実行できる
  before_action(:redirect_if_not_logged_in, {
    only: [:index, :edit, :update, :destroy, :following, :followers]
  })
  before_action(:redirect_if_not_authenticated, { only: [:edit, :update] })
  before_action(:redirect_if_not_admin, { only: [:destroy] })
  # TODO: debugしなくなったら消す
  attr_reader :user, :current_user

  def index
    @users = User
      .where(activated: true)
      .paginate(page: params[:page])
  end
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to(root_url) and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(get_validated_user_params)
    if @user.save
      @user.send_activation_email
      # redirect_to user_url(@user) と等価
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
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

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "User #{params[:id]} - #{user.name} deleted."
    redirect_to(users_url)
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render('show_follow')
  end

  def followers
    @title = "Follower"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render('show_follow')
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

    # 認証中のユーザでなければ強制リダイレクト
    def redirect_if_not_authenticated
      @user = User.find(params[:id])
      current_user = get_current_user_or_nil
      if current_user != @user
        redirect_to(root_url)
      end
    end

    # 管理者でなければ強制リダイレクト
    def redirect_if_not_admin
      current_user = get_current_user_or_nil
      redirect_to(root_url) unless current_user.admin?
    end
end
