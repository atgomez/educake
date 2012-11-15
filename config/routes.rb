TeacherMgnt::Application.routes.draw do
  root :to => "home#index"
  resources :teachers do 
    collection do 
      get :show_charts
      get :all_students
    end 
  end 
  resources :invitations 

  resources :students do 
    member do 
      get :load_users
      get :load_status
      get :search_user
      get :common_chart
    end
    collection do 
      get :chart
      get :load_grades
    end 
  end

  resources :goals do 
    collection do 
      get :new_status 
      post :add_status
      get :initial_import_grades
      put :import_grades
    end

    member do
      put :update_status
    end
  end 

  devise_for :users, :controllers => { :registrations => 'user_registrations', 
    :confirmations => 'user_confirmations'}

  as :user do
    match '/user/confirmation' => 'user_confirmations#update', :via => :put, :as => :update_user_confirmation
  end

  get '/admin', :to => "admin/base_admin#index"
  namespace :admin do
    resources :teachers do
      collection do
        get :search
        get :show_charts
        get :show_teachers_chart
        get :all
        get :get_students
      end

      member do
        get :all_students
      end
    end

    resources :students do 
      member do 
        get :load_users
        get :load_status
        get :search_user
        get :load_grades
        get :common_chart
      end 
    end
  end

  resources :curriculum
end
