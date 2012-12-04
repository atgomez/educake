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
  
  def admin_confirmation(user, password) 
    @user = user
    @url = url_for :controller=>'devise/sessions', :action => 'new'
    @password = password
    if user.is_admin_school?
      subject = "Confirmation for admin account"
    elsif user.is_not_admin?
      subject = "Confirmation for user account"
    end 
    mail(:to => user.email, :subject => subject)
  end
  
  def send_reset_password(user, password)
    @user = user
    @password = password
    @url = url_for :controller=>'devise/sessions', :action => 'new'

    mail(:to => user.email, :subject => "Reset Password")
  end 
end
