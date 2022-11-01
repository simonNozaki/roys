module SessionsHelper
  # ログイン、セッション情報を保持する
  # @param [User] user
  def log_in(user)
    # ActionDispatch::Request::Session にある []= をコールしている
    # session自体は ActionDispatch::Request::Session のインスタンスメソッド
    session[:user_id] = user.id
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def get_current_user_or_nil
    user_id = session[:user_id]
    if user_id
      @current_user ||= User.find_by(id: user_id)
    end
  end

  def logged_in?
    get_current_user_or_nil.present?
  end
end
