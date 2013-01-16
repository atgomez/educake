class UserMailer < ActionMailer::Base
  default from: "teacher@gmail.com"

  def invited_confirmation(sharing) 
    @sharing = sharing
    @existed = User.exists?(:email => sharing.email)
    if @existed
      @url = url_for :controller=>'devise/sessions', :action => 'new'
    else
      @url = url_for :controller=>'devise/user_registrations', :action => 'new'
    end 
    mail(:to => sharing.email, :subject => I18n.t("mail.user.invitation_confirm_subject"))
  end
  
  def send_reset_password(user, password)
    @user = user
    @password = password
    @url = url_for :controller=>'devise/sessions', :action => 'new'
    mail(:to => user.email, :subject => I18n.t("mail.user.reset_password_subject"))
  end
  
  def inform_blocked_account(user)
    @user = user
    @url = url_for :controller=>'devise/sessions', :action => 'new'
    mail(:to => user.email, :subject => I18n.t("mail.user.inform_block_status_subject"))
  end

  def send_notify_subscriber(subscriber)
    @subscriber = subscriber 
    @super_admin = User.super_admins.first
    mail(:to => "thuy.nguyen@techpropulsionlabs.com", :subject => I18n.t("mail.notify_subscriber"))
  end
end
