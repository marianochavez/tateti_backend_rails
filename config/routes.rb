Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :boards do
        member do
          put 'join-game', as: :join_game
          put :play
        end
      end

      resources :users, only: [:index, :create] do
        member do
          post :disable
          post :enable
        end
        collection do
          post 'sign-in', as: :sing_in
          get 'sing-out', as: :sign_out
          # post :password #TODO: delete?
        end
      end
    end
  end
end
