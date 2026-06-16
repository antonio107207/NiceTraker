Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  post "/locale", to: "locales#update", as: :switch_locale

  authenticate :user do
    root to: "dashboard#index"

    resources :workspaces do
      resources :boards, shallow: true do
        member { post :invite }
        resources :labels, only: %i[create destroy], shallow: true
        resources :lists, shallow: true do
          member { patch :move }
          resources :cards, shallow: true do
            member { patch :move }
            resources :card_labels,      only: %i[create destroy], shallow: true
            resources :card_memberships, only: %i[create destroy], shallow: true
            resources :card_relations,   only: %i[create] do
              collection { get :search }
            end
            resources :checklists, shallow: true do
              resources :checklist_items, shallow: true
            end
            resources :comments, shallow: true
            resources :attachments, only: %i[create destroy], shallow: true
            resources :time_entries, only: %i[create update destroy], shallow: true
          end
        end
      end
    end

    resources :board_memberships,     only: %i[destroy]
    resources :workspace_memberships, only: %i[destroy]
    resources :card_relations,        only: %i[destroy]

    # Shareable card URL: /boards/:board_id/cards/:id → cards#show
    get "/boards/:board_id/cards/:id", to: "cards#show", as: :board_card

    resources :invitations, only: %i[show], param: :token do
      member do
        post :accept
        post :decline
      end
    end

    resources :notifications, only: %i[index] do
      collection { patch :mark_all_read }
      member { patch :mark_read }
    end

    get "search", to: "search#index"

    get  "reports",        to: "reports#index",  as: :reports
    get  "reports/export", to: "reports#export", as: :export_reports
  end

  unauthenticated do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
