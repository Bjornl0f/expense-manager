Rails.application.routes.draw do
  resources :expenses
  resources :categories
  resources :payment_methods
  resources :spenders
  
  get '/import_export', to: 'import_export#index', as: 'import_export'
  get '/export_json', to: 'import_export#export_json'
  get '/export_yaml', to: 'import_export#export_yaml'
  post '/import', to: 'import_export#import'
  
  root to: 'expenses#index'
end