class UserMailer < ActionMailer::Base
  default from: "teacher@gmail.com"
  def invited_confirmation(user) 
    @user = user
    @existed = User.exists?(:email => user.email)
    if @existed
      @url = url_for :controller=>'devise/sessions', :action=>'new'
    else
      @url = url_for :controller=>'devise/registrations', :action=>'new'
    end 
    mail(:to => user.email, :subject => "Confirmation for inviting")
  end
end
