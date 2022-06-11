class Api::V1::UsersController < ApplicationController

  before_action :set_user, only: [:sign_out]
  before_action :check_token, only: [:sign_out]

  def index
    users = User.all
    render json: { data: users }, status: :ok
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: { data: user }, status: :created
    else
      render json: { error: user.errors }, status: :unprocessable_entity
    end
  end

  def sign_in
    user = User.find_by(username: params[:username])

    if user.present? && user.authenticate(params[:password])
      user.set_token
      user.save
      render json: { data: user }, status: :ok
    else
      error = user.blank? ? 'User does not exist' : 'Invalid password'
      render json: { error: error }, status: :bad_request
    end
  end

  def sign_out
    @user.set_token
    if @user.save
      render status: :ok
    else
      render status: :bad_request
    end
  end

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation)
  end

end
