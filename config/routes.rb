TeacherMgnt::Application.routes.draw do
  root :to => "home#index"
  resources :teachers
  resources :invitations
  resources :students do 
    member do 
      get :load_users
      get :load_status
    end 
  end
  resources :goals do 
    collection do 
      get :new_status 
      post :add_status
    end 
  end 

  devise_for :users
  
  get '/admin', :to => "admin/base_admin#index"
  namespace :admin do
    resources :teachers 
    resources :students do 
      member do 
        get :load_users
        get :load_status
      end 
    end
  end

  resources :curriculum
end
