class UserMailer < ActionMailer::Base
  default from: "teacher@gmail.com"
  def invited_confirmation(user) 
    @user = user
    @url = url_for :controller=>'devise/registrations', :action=>'new'
    mail(:to => user.email, :subject => "Confirmation for inviting")
  end
end
