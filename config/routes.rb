Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users
    
    resources :expenses
    resources :categories
    resources :payment_methods
    resources :spenders
    
    get '/import_export', to: 'import_export#index'
    post '/import', to: 'import_export#import'
    get '/export_json', to: 'import_export#export_json'
    get '/export_yaml', to: 'import_export#export_yaml'
    
    root 'expenses#index'
  end
end