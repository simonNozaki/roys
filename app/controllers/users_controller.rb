class UsersController < ApplicationController
  before_action(:logged_in_user, { only: [:edit, :update] })

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
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
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

    def logged_in_user
      if not logged_in?
        flash[:danger] = "Please log in."
        redirect_to(login_url)
      end
    end
end
