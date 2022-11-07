class User < ApplicationRecord
  REGEX_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  attr_accessor :remember_token, :activation_token

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

  def activated?(activation_token)

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
