class User < ApplicationRecord
  REGEX_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  before_save(-> {
    # DBごとの大文字小文字区別状況を無視させるため
    email.downcase!
  })

  validates(:name, { presence: true, length: { maximum: 50 }})
  validates(:email, {
    presence: true, length: { maximum: 255 } ,
    format: { with: REGEX_EMAIL_FORMAT },
    # case sensitiveオプションがつくと自動的に一意判定になる
    uniqueness: { case_sensitive: false }
    }
  )
  validates(:password, {
    presence: true, length: { minimum: 6 }
  })

  has_secure_password

  # 引数のハッシュ文字列を返す
  # @param [String] str
  def self.digest(str)
    cost = ActiveModel::SecurePassword.min_cost ?
      BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    
    return BCrypt::Password.create(str, cost: cost)
  end
end
