class UserMailer < ActionMailer::Base
  default from: "teacher@gmail.com"
  def invited_confirmation(user) 
    @user = user
    @existed = User.exists?(:email => user.email)
    if @existed
      @url = url_for :controller=>'devise/sessions', :action => 'new'
    else
      @url = url_for :controller=>'/user_registrations', :action => 'new'
    end 
    mail(:to => user.email, :subject => "Confirmation for inviting")
  end
  
  def admin_confirmation(user) 
    @user = user
    @url = url_for :controller=>'devise/sessions', :action => 'new'
    if user.is_admin_school?
      subject = "Confirmation for admin account"
    elsif user.is_not_admin?
      subject = "Confirmation for user account"
    end 
    mail(:to => user.email, :subject => subject)
  end
  
end
