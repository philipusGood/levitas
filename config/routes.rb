require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  constraints FlipperUI do
    mount Flipper::UI.app(Flipper) => '/flipper'
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
    mount MaintenanceTasks::Engine => "/maintenance_tasks"
  end

  devise_for :users, :controllers => {:registrations => "registrations"}

  devise_scope :user do
    get 'sign_up/broker', to: 'registrations#new', as: :new_broker_registration
    get 'sign_up/lender', to: 'registrations#new', as: :new_lender_registration
    get 'profile/edit', to: 'registrations#edit', as: :edit_profile
  end

  resource :after_signup, only: %i[show update]
  resources :brokers do
    member do
      post :send_invite
      get :lenders_pool
      post :remove_lender_from_pool
    end
  end

  resources :dashboard, only: [:index] do
    collection do
      post :filters_sidebar
    end
  end

  resources :deals do
    resources :main_applicant, only: [:index, :show, :update], controller: 'deals/main_applicant'
    resources :secondary_applicant, only: [:index, :show, :update], controller: 'deals/secondary_applicant'
    resources :guarantor, only: [:index, :create], controller: 'deals/guarantors'
    resources :property, only: [:index, :create], controller: 'deals/properties'
    resources :terms, only: [:index, :create], controller: 'deals/terms'
    resources :loan_purpose, only: [:index, :create], controller: 'deals/loan_purpose'
    resources :documents, only: [:index, :create, :edit, :update, :destroy], controller: 'deals/documents' do
      collection do
        post :upload
        post :upload_ai
      end

      member do
        post :change_visibility
        post :download
      end
    end
    resources :documents, only: [:index, :create, :destroy], controller: 'deals/documents'
    resources :broker_fee, only: [:index, :create], controller: 'deals/broker_fees'
    resources :credit_check, only: [:index, :create], controller: 'deals/credit_check'
    resources :summary, only: [:index], controller: 'deals/summary'
    resources :submit, only: [:index, :create], controller: 'deals/submit'
    resources :view, only: [:index], controller: 'deals/view'

    member do
      post :bookmark
      post :change
      post :review
      post :reject
      get  :reject
      post :reject_reason
      post :accept
      post :start_funding
      post :request_signatures
      post :approve_signatures
      post :make_public
      get  :make_public_modal
      post :set_credit_score
      get  :review_terms_modal
      get  :invite_lenders_modal
      get  :view_invited_lenders_modal
      post :upload_document
      get :signing_complete
      post :download_document
    end

    collection do
      get :selected_lenders_counter, to: 'deals/lenders#selected_lenders_counter'
      post :invite_lender_add, to: 'deals/lenders#invite_lender_add'
    end

    resources :lenders, controller: 'deals/lenders', only: [:create, :destroy] do
      member do
        post :commit_capital
        post :send_signature_reminder
        get  :review_investment_modal
        post :review_investment_modal
        post :sign_deal
      end

      collection do
        post :search_lenders_autocomplete
      end
    end
  end

  resources :lenders do
    member do
      post :send_invite
      post :remove_from_pool
      post :approve_lender
    end

    collection do
      post :invite_lenders
      get  :invite_lenders_modal
      post :search_lenders_autocomplete
    end
  end

  resources :impersonations, only: [:create]

  resource :profile, only: [:show]

  resource :resend_confirmation, only: [:create]

  resources :marketplace, only: [:index, :show] do
    collection do
      post :filters_sidebar
    end
  end

  namespace :lender do
    resources :brokers, only: [:index] do
      collection do
        post :accept_invitation
        post :reject_invitation
      end
    end
  end

  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
  end

  resources :notifications, only: [:destroy] do
    member do
      post :router
    end

    collection do
      post :sidebar
      delete :delete_all
    end
  end

  namespace :webhooks do
    resources :docusign, only: [:create]
  end

  get 'switch_locale/:locale', to: 'locale#switch', as: 'switch_locale'

  root to: redirect('/users/sign_in')

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
