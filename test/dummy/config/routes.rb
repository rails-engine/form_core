Rails.application.routes.draw do

  resources :dictionaries, except: [:show]

  resources :forms do
    scope module: :forms do
      resource :preview, only: [:show, :create]
      resources :sections, except: [:show]
      resources :fields, except: [:show]
    end
  end

  resources :fields, only: [] do
    scope module: :fields do
      resource :validations, only: [:edit, :update]
      resource :options, only: [:edit, :update]
      resource :data_source_options, only: [:edit, :update]
    end
  end

  resources :nested_forms, only: [] do
    scope module: :nested_forms do
      resources :fields, except: [:show]
    end
  end

  root to: 'home#index'
end
