class UserMailer < ApplicationMailer
  default from: "no_replay@inocrm.com"
  default to: "umesh.m@mailinator.com"

  def welcome_email(*args)
    options = args.extract_options!
    options[:content_type] = "text/html"
    # @user = user
    # email_with_name = %(umeshblader@gmail.com)
    mail(options)
  end
end
