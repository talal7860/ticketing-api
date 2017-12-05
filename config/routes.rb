Rails.application.routes.draw do
  mount ApplicationApi, at: "/"
  #root to: redirect(ENV.fetch('BASE_URL', "http://localhost:3000/"))
  get '/reports', to: 'reports#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
