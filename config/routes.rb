TeacherMgnt::Application.routes.draw do
  resources :schools

  resources :export do
    collection do
      get :export_student
    end
  end

  root :to => "home#index"
  match "blocked_account" => "home#show_blocked_account"
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
      get :load_grade
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
      get :new_grade 
      post :add_grade
      get :initial_import_grades
      put :import_grades
    end

    member do
      put :update_grade
    end
  end 

  devise_for :users, :controllers => { :registrations => 'user_registrations', 
    :confirmations => 'user_confirmations'}

  as :user do
    match '/user/confirmation' => 'user_confirmations#update', :via => :put, :as => :update_user_confirmation
  end

  get '/admin', :to => "admin/base_admin#index"
  get '/super_admin', :to => "super_admin/base_super_admin#index"
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
        get :load_grade
        get :search_user
        get :load_grades
      end 
      collection do 
        get :load_grades
      end 
    end
  end
  
  namespace :super_admin do 
    resources :schools  
    resources :users do 
      member do 
        put :blocked_account
        put :reset_password
        get :view_as
      end
      collection do 
        get :search_result
      end 
    end
  end 

  resources :curriculum
end
