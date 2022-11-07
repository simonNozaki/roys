class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activate_account.subject
  # @param [User] user
  def activate_account(user)
    @user = user
    mail(to: user.email, subject: "Account activation")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password.subject
  #
  def reset_password
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
