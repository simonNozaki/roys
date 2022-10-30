class UsersController < ApplicationController
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
      # redirect_to user_url(@user) と等価
      flash[:success] = "Welcome to the Roys!"
      redirect_to @user
    else
      render "new"
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
end
