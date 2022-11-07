# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/activate_account
  def activate_account
    user = User.first
    user.activation_token = User.get_new_token
    UserMailer.activate_account(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/reset_password
  def reset_password
    UserMailer.reset_password
  end

end
