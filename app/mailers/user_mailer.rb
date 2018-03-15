class UserMailer < ApplicationMailer
  default from: "helpdesk@vsis.lk"
  default to: "umesh.m@mailinator.com"

  def welcome_email(body, *args)
    options = args.extract_options!
    # options[:content_type] = "text/html"
    # @user = user
    # email_with_name = %(umeshblader@gmail.com)
    @body = body
    # attachments.inline['header.jpeg'] = File.read(Rails.root.join('app', 'assets', 'images', 'header.jpeg'))
    mail(options)
  end

  def sample_email
    attachments.inline['header.jpeg'] = File.read(Rails.root.join('app', 'assets', 'images', 'header.jpeg'))
  	email_with_name = "umesh.m@inovaitsys.com"
  	mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
  end
end
