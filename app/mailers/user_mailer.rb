class UserMailer < ApplicationMailer
  def invite_user(user)
    @user = user
    mail(to: user.email, subject: 'You have been invited to join customer support')
  end
end
