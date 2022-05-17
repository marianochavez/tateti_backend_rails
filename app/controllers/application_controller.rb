class ApplicationController < ActionController::API

  def set_user
    @user ||= User.find_by(token: header_token)
    return if @user.present?

    render json: { error: 'User not found' }, status: :not_found
  end

  def header_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    else
      nil
    end
  end

  #TODO check
  def check_token
    return if header_token.present? && header_token == @user.token

    render json: { error: 'Token error' }, status: :unauthorized
  end
end
