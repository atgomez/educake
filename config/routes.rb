TeacherMgnt::Application.routes.draw do
  root :to => "home#index"
  resources :teachers
  resources :students do 
    member do 
      get :load_users
      get :load_status
    end 
  end
  resources :goals
  devise_for :users
end
