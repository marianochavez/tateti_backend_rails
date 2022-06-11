Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :boards, only: [:index,:show,:create] do
        member do
          put :play
          put :leave
          get :historical
        end
        collection do
          # cambiar a member, pasar el token por id
          put 'join-game', as: :join_game
        end
      end

      resources :users, only: [:index, :create] do
        collection do
          post 'sign-in', as: :sing_in
          post 'sign-out', as: :sign_out
        end
      end
    end
  end
end
