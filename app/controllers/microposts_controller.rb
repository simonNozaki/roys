class MicropostsController < ApplicationController
  before_action(:redirect_if_not_logged_in, { only: [:create, :destroy] })
  before_action(:redirect_if_not_authenticated, { only: [:destroy] })
  def create
    user = get_current_user_or_nil
    unless user
      raise StandardError("User cannot post micropost if not logged on.")
    end
    @micropost = user.microposts.build(get_validated_microposts_params)
    p params[:micropost][:image]
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Microposts created!"
      redirect_to(root_url)
    else
      @feed_items = user.get_microposts.paginate(page: params[:page])
      render('static_pages/home')
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_back({ fallback_location: root_url })
  end

  private
    def get_validated_microposts_params
      params
        .require(:micropost)
        .permit(
          :content,
          :image
        )
    end

    def redirect_if_not_authenticated
      user = get_current_user_or_nil
      # ログインしていなければ削除できない
      if user.nil?
        redirect_to(root_url)
      end
      @micropost = user.microposts.find_by({ id: params[:id] })
      if @micropost.nil?
        redirect_to(root_url)
      end
    end
end
