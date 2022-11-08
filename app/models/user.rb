class User < ApplicationRecord
  REGEX_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save(-> {
    # DBごとの大文字小文字区別状況を無視させるため
    email.downcase!
  })
  before_create(-> { create_activation_digest(self) })

  validates(:name, { presence: true, length: { maximum: 50 }})
  validates(:email, {
    presence: true, length: { maximum: 255 } ,
    format: { with: REGEX_EMAIL_FORMAT },
    # case sensitiveオプションがつくと自動的に一意判定になる
    uniqueness: { case_sensitive: false }
    }
  )
  validates(:password, {
    presence: true,
    length: { minimum: 6 },
    allow_nil: true
  })
  # User#createがコールされるときに呼ばれる
  # ActiveModel::SecurePassword::ClassMethods / https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  has_secure_password

  def remember
    self.remember_token = User.get_new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 引数のトークンがダイジェストと一致したらtrueを返す
  # @param [String] remember_token
  def authenticated?(remember_token)
    if remember_digest.nil?
      return false
    end
    BCrypt::Password.new(self.remember_digest).is_password?(remember_token)
  end

  # 引数のトークンがダイジェスト値と一致したらtrueを返す
  # @param [String] activation_token
  def is_activated?(activation_token)
    if activation_digest.nil?
      return false
    end
    BCrypt::Password.new(self.activation_digest).is_password?(activation_token)
  end

  # リセットトークンがダイジェスト値と一致したらtrueを返す
  def reset?(reset_token)
    if reset_digest.nil?
      return false
    end
    BCrypt::Password.new(self.reset_digest).is_password?(reset_token)
  end

  # 有効化属性を更新する
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # アカウント有効確認メールを送信する
  def send_activation_email
    UserMailer.activate_account(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.get_new_token
    update_columns(
      reset_digest: User.digest(self.reset_token),
      reset_sent_at: Time.zone.now
    )
  end

  # パスワード再設定メールを送信する
  def send_password_reset_email
    UserMailer.reset_password(self).deliver_now
  end

  # パスワード再設定要求が有効期限切れならtrueを返す
  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end

  # ユーザのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # 引数のハッシュ文字列を返す
  # @param [String] str
  def self.digest(str)
    cost = ActiveModel::SecurePassword.min_cost ?
      BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    
    return BCrypt::Password.create(str, cost: cost)
  end

  def self.get_new_token
    SecureRandom.urlsafe_base64
  end

  private
    # ユーザの有効化ダイジェストを生成する
    # @param [User] user
    # @@return user
    def create_activation_digest(user)
      user.activation_token = User.get_new_token
      user.activation_digest = User.digest(activation_token)
      user
    end
end
