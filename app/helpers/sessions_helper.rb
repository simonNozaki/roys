module SessionsHelper
  # ログイン、セッション情報を保持する
  # @param [User] user
  def log_in(user)
    # ActionDispatch::Request::Session にある []= をコールしている
    # session自体は ActionDispatch::Request::Session のインスタンスメソッド
    session[:user_id] = user.id
  end

  # ユーザのセッションを永続化する
  # @param [User] user
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # ユーザのセッションを破棄する
  # @param [User] user
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    @current_user = nil
  end

  def log_out
    current_user = get_current_user_or_nil
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 記憶トークンcookieに対応するユーザを返す
  def get_current_user_or_nil
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user&.authenticated?(cookies[:remember_token])
        log_in(user)
        @current_user = user
      end
    end
  end

  def logged_in?
    get_current_user_or_nil.present?
  end
end
