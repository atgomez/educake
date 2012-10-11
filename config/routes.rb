TeacherMgnt::Application.routes.draw do
  resources :students do 
    member do 
      get :load_users
      get :load_status
    end 
  end 

  root :to => "home#index"
  resources :teachers

#/students/:id/load_users
  devise_for :users
end
