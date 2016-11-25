class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    email_with_name = %(umeshblader@gmail.com)
    mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
  end
end
