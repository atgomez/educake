TeacherMgnt::Application.routes.draw do
  root :to => "home#index"
  resources :teachers
  resources :invitations 

  resources :students do 
    member do 
      get :load_users
      get :load_status
      get :search_user
      get :common_chart
    end
  end

  resources :goals do 
    collection do 
      get :new_status 
      post :add_status
    end

    member do
      put :update_status
    end
  end 

  devise_for :users, :controllers => { :registrations => 'user_registrations'}
  
  get '/admin', :to => "admin/base_admin#index"
  namespace :admin do
    resources :teachers do
      collection do
        get :search
      end
    end

    resources :students do 
      member do 
        get :load_users
        get :load_status
        get :search_user
      end 
    end
  end

  resources :curriculum
end
