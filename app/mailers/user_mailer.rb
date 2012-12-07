class UserMailer < ActionMailer::Base
  default from: "teacher@gmail.com"
  def invited_confirmation(user) 
    @user = user
    @existed = User.exists?(:email => user.email)
    if @existed
      @url = url_for :controller=>'devise/sessions', :action => 'new'
    else
      @url = url_for :controller=>'devise/user_registrations', :action => 'new'
    end 
    mail(:to => user.email, :subject => "Confirmation for inviting")
  end
  
  def send_reset_password(user, password)
    @user = user
    @password = password
    @url = url_for :controller=>'devise/sessions', :action => 'new'

    mail(:to => user.email, :subject => "Reset Password")
  end 
end
