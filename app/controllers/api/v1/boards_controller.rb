class Api::V1::BoardsController < ApplicationController
  before_action :set_board, only: [:show, :play, :leave]
  before_action :find_by_token, only: [:join_game]
  before_action :check_state, only: [:join_game, :play]
  before_action :set_user, only: [:create, :join_game, :play, :show, :leave]
  before_action :check_token, only: [:create, :join_game, :play, :show, :leave]

  def index
    @boards = Board.all
    render json: { data: @boards }, status: :ok
  end

  def show
    if @board.users.length == 2
      if @board.state == 'Playing'
        @board.set_my_turn(@user)
      else
        @board.myTurn = false
      end
      render json: { board: @board, X: @board.users[0].name, O: @board.users[1].name }, status: :ok
    else
      render json: { board: @board, X: @board.users[0].name }, status: :ok
    end
  end

  def create
    @board = Board.new
    @board.initialize_board(@user)
    if @board.save
      render json: { data: @board }, status: :created
    else
      render json: { error: @board.errors }, status: :bad_request
    end
  end

  def join_game
    unless @board.can_join?(@user)
      return render json: { error: 'Not possible to join' }, status: :bad_request
    end

    unless @board.valid_token?(params[:token])
      return render json: { error: 'Board token is not valid' }, status: :bad_request
    end

    @board.join_game(@user)
    if @board.save
      render json: { data: @board }, status: :ok
    else
      render json: { error: @board.errors }, status: :unprocessable_entity
    end
  end

  def play

    unless @board.valid_turn?(@user)
      return render json: { error: 'This is not your turn' }, status: :unprocessable_entity
    end

    unless @board.valid_place?(params[:index])
      return render json: { error: 'This place is not available' }, status: :unprocessable_entity
    end

    @board.insert_in(params[:index])
    if @board.winner?(@user)
      @board.set_winner(@user)
    else
      if @board.draw?
        @board.set_draw
      else
        @board.set_turn
        @board.set_my_turn(@user)
      end
    end
    @board.save
    render json: { board: @board, X: @board.users[0].name, O: @board.users[1].name }, status: :ok
  end

  def historical
    @user1 = User.find_by(username: params[:username_1])
    @user2 = User.find_by(username: params[:username_2])
    
    if @user2.present?
      @boards = @user1.boards.filter { |board| board.users.include? @user2 }
    else
      @boards = @user1.boards
    end

    render json: { data: @boards }, status: :ok
  end

  def leave
    unless @board.users.ids.include? @user.id
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    @board.state = 'Finished'
    if @board.save
      render json: {data: @board}, status: :ok
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
