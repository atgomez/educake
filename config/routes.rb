TeacherMgnt::Application.routes.draw do
  resources :students

  root :to => "home#index"
  resources :teachers


  devise_for :users
end
