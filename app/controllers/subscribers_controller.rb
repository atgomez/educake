class SubscribersController < ApplicationController
  skip_before_filter :authenticate_user!

  def new
    @subscriber = Subscriber.new
  end

  def create
    @subscriber = Subscriber.new(params[:subscriber])

    if @subscriber.save
      UserMailer.send_notify_subscriber(@subscriber).deliver
      redirect_to new_subscriber_path, notice: I18n.t("subscribers.created_successfully")
    else
      render action: "new"
    end
  end

  
end
