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
end
