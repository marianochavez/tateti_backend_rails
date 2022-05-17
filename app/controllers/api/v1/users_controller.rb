class Api::V1::UsersController < ApplicationController

  before_action :set_user, only: [:enable, :disable, :password]
  before_action :check_token, only: [:enable, :disable]

  def index
    @users = User.all
    render json: { data: @users }, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: { data: @user }, status: :created
    else
      render json: { error: @user.errors }, status: :unprocessable_entity
    end
  end

  def enable
    if @user.update(enabled: true)
      render json: { data: @user }, status: :ok
    else
      render json: { error: @user.errors }, status: :bad_request
    end
  end

  def disable
    if @user.update(enabled: false)
      render json: { data: @user }, status: :ok
    else
      render json: { error: @user.errors }, status: :bad_request
    end
  end

  def sign_in
    @user = User.find_by(username: params[:username])
    #todo: check if enabled

    if @user.present? && @user.authenticate(params[:password])
      @user.generate_token
      render json: { data: @user }, status: :ok
    else
      error = @user.blank? ? 'User does not exist' : 'Invalid password'
      render json: { error: error }, status: :bad_request
    end
  end

  def sign_out
    if @user.generate_token
      render status: :ok
    else
      render status: :bad_request
    end
  end

  #TODO delete??
  def password
    if @user.authenticate(params[:password])
      if @user.update(params.permit(:password, :password_confirmation))
        render json: { data: @user }, status: :ok
      else
        render json: {error: @user.errors}
      end
    else
      render json: {error: 'Invalid password'},status: :unauthorized
    end
  end

  #TODO def current

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation)
  end

end
