TeacherMgnt::Application.routes.draw do
  #Rails Admin
  mount RailsAdmin::Engine => '/backend', :as => 'rails_admin'

  #Logger
  mount MongodbLogger::Server.new, :at => "/mongodb"
  mount MongodbLogger::Assets.instance, :at => "/mongodb/assets", :as => :mongodb_assets # assets

  # Config for dynamic root url
  # DO NOT change the order of the root config, otherwise it will not work properly
  # root :to => "super_admin/schools#index", :constraints => RoleRouteConstraint.new(:super_admin)
  # root :to => "admin/teachers#index", :constraints => RoleRouteConstraint.new(:admin)
  # root :to => "students#index", :constraints => RoleRouteConstraint.new(:parent, :teacher)
  root :to => "home#index"
  resources :subscribers
  # Chart rooting
  resources :charts do
    collection do
      get :user_chart
      get :student_chart
      get :goal_chart
    end
  end

  resources :export do
    collection do
      get :relay
      get :export_student
      get :export_classroom
      get :export_school
    end
  end

  resources :invitations 

  resources :students do 
    member do 
      get :load_users
      get :load_grade
    end
    collection do 
      get :load_grades
      get :all_students
      get :search_user
    end 
  end

  resources :goals do 
    collection do 
      get :new_grade 
      post :add_grade
      get :initial_import_grades
      put :import_grades
      get :load_grades
      post :curriculum_info
    end

    member do
      put :update_grade
    end
  end 

  devise_for :users, :controllers => { :registrations => 'devise/user_registrations', 
    :confirmations => 'devise/user_confirmations'}

  as :user do
    match '/user/confirmation' => 'devise/user_confirmations#update', :via => :put, :as => :update_user_confirmation
  end

  devise_scope :user do
    get :my_account, :to => 'profile#show'
    post :change_password, :to => 'profile#change_password'
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
  end
  
  namespace :super_admin do 
    resources :schools
    resources :subscribers do 
      member do 
        get :contact
      end 
    end
    resources :curriculums do
      collection do
        get :init_import
        post :import
      end
    end

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
end
