class SuperAdmin::SubscribersController < SuperAdmin::BaseSuperAdminController

  def index
    @subscribers = Subscriber.load_data(filtered_params)
  end
  
end