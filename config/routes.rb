TeacherMgnt::Application.routes.draw do
  root :to => "home#index"
  resources :teachers


  devise_for :users
end
