# frozen_string_literal: true

Rails.application.routes.draw do

  resources :dictionaries, except: %i[show]

  resources :forms, except: %i[show] do
    scope module: :forms do
      resource :preview, only: %i[show create]
      resource :load, only: %i[show create]
      resources :sections, except: %i[show]
      resources :fields, except: %i[show]
    end
  end

  resources :fields, only: %i[] do
    scope module: :fields do
      resource :validations, only: %i[edit update]
      resource :options, only: %i[edit update]
      resource :data_source_options, only: %i[edit update]
      resources :choices, except: %i[show]
    end
  end

  resources :nested_forms, only: %i[] do
    scope module: :nested_forms do
      resources :fields, except: %i[show]
    end
  end

  root to: "forms#index"

  resource :time_zone, only: [:update]
end
