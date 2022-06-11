class Api::V1::BoardsController < ApplicationController
  before_action :set_user, only: [:create, :join_game, :play, :show, :leave]
  before_action :check_token, only: [:create, :join_game, :play, :show, :leave] #user
  before_action :set_board, only: [:show, :play, :leave, :join_game]
  before_action :check_state, only: [:join_game, :play, :leave]

  def index
    boards = Board.filter(params.slice(:user_1, :user_2, :state))
    render json: { data: boards }, status: :ok
  end

  def show
    render json: { board: @board }, status: :ok
  end

  def create
    board = Board.new
    board.create_game(@user["username"])
    if board.save
      render json: { data: board }, status: :created
    else
      render json: { error: board.errors }, status: :bad_request
    end
  end

  def join_game
    unless @board.can_join?(@user)
      return render json: { error: 'Not possible to join' }, status: :bad_request
    end

    @board.join_game(@user["username"])
    if @board.save
      render json: { data: @board }, status: :ok
    else
      render json: { error: @board.errors }, status: :unprocessable_entity
    end
  end

  def play
    unless @board.can_play?(@user["username"])
      return render json: { error: 'You can not play' }, status: :unprocessable_entity
    end

    unless @board.valid_place?(params[:index])
      return render json: { error: 'This place is not available' }, status: :unprocessable_entity
    end

    @board.play(params[:index], @user["username"])
    if @board.save
      render json: { board: @board }, status: :ok
    else
      render json: { error: @board.errors }, status: :unprocessable_entity
    end

  end

  def leave
    unless @board.can_leave?(@user["username"])
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    @board.set_winner('Abandonada')
    @board.set_state(4)
    if @board.save
      render json: { data: @board }, status: :ok
    end
  end

  private

  def set_board
    @board = Board.find(params[:id])
    return if @board.present?

    render json: { error: 'Board not found' }, status: :not_found
    false
  end

  def check_state
    return if @board.state != "Finished"

    render json: { data: "The game is over, the winner is #{@board.winner}" }, status: :bad_request
    false
  end

  def find_by_token
    @board = Board.find_by(token: params[:token])
    return if @board.present?

    render json: { error: 'Board not found' }, status: :not_found
    false
  end

end
