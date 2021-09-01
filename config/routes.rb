Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions',
                                    registrations: 'users/registrations' }
  devise_scope :user do
    root to: 'users/sessions#new'
    delete 'sign_out', to: 'users/sessions#destroy'
    get 'sign_out', to: 'users/sessions#destroy'
  end

  get :guidelines, to: 'pages#guidelines'
  resources :feedbacks, path: :feedback do
    member do
      patch :add_reply
    end
  end
  get 'dashboards', to: 'proposal_types#index'

  resources :submitted_proposals do
    collection do
      get :download_csv
      post :edit_flow
    end
    member do
      post :staff_discussion
      post :send_emails
      post :approve_status
      post :decline_status
    end
  end

  get :invite, to: 'invites#show'
  get 'expired' => 'invites#expired'
  post 'cancel' => 'invites#cancel'

  resources :proposals do
    post :latex, to: 'proposals#latex_input'
    member do
      get :rendered_proposal, to: 'proposals#latex_output'
      get :rendered_field, to: 'proposals#latex_field'
      patch :ranking
      get :locations
      post :upload_file
      post :remove_file
    end

    resources :invites, except: [:show] do
      member do
        post :inviter_response
        post :invite_reminder
        post :invite_email
      end
      collection do
        get :thanks
      end
    end
  end

  resources :survey do
    collection do
      get :survey_questionnaire
      get :faqs
      post :submit_survey
    end
  end

  resources :people, path: :person

  resources :submit_proposals do
    collection do
      get :thanks
    end
  end
  resources :proposal_types do
    resources :proposal_forms do
      member do
        post :clone
        delete :proposal_field
        get :proposal_field_edit
      end
      resources :proposal_fields do
        collection do
          post :latex_text
        end
      end
    end
    member do
      get :location_based_fields
      get :proposal_type_locations
    end
  end
  resources :locations do
    member do
      get :proposal_types
    end
  end
  resources :page_contents

  resources :faqs do
    member do
      patch :move
    end
  end

  get 'profile/' => 'profile#edit'
  patch 'update' => 'profile#update'
  post 'demographic_data' => 'profile#demographic_data'

  resources :roles do
    member do
      post :new_user
      post :new_role
      post :remove_role
    end
  end

  resources :subject_categories do
    resources :subjects
    resources :ams_subjects
  end

  resources :emails do
    collection do
      patch :email_template
    end
  end

  resources :email_templates
end
