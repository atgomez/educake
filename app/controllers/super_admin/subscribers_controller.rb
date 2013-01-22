class SuperAdmin::SubscribersController < SuperAdmin::BaseSuperAdminController

  def index
    @subscribers = Subscriber.load_data(filtered_params)
  end

  def contact
    @subscriber = Subscriber.find params[:id] 
    @subscriber.update_attribute(:is_accept, true)
    subscribers = Subscriber.load_data(filtered_params)
    render :partial => "list_subscribers", :locals => {:subscribers => subscribers}
  end 
  
end