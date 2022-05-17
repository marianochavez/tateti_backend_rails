class Board < ApplicationRecord

  has_and_belongs_to_many :users, join_table: 'users_boards'

  serialize :table #save an object

  def initialize_board(current_user)
    self.table = {}
    self.state = 'Queue'
    self.turn = rand(2) == 0 ? 'X' : 'O'
    self.users.push(current_user)
  end

  def join_game(current_user)
    self.users.push(current_user)
    self.state = 'Playing'
  end

  def user_symbol(user)
    self.users.index(user) == 0 ? 'X' : 'O'
  end

  def insert_in(index)
    i = index.to_i
    self.table[i] = turn
  end

  def winner?(current_user)
    turn = user_symbol(current_user)

    positions_turn = []
    self.table.each do |key, value|
      if value == turn
        positions_turn.push(key)
      end
    end
    winning_position = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ]

    winning_position.each { |position|
      if position - positions_turn == []
        return true
      end
    }
    false
  end

  def draw?
    self.table.length == 9
  end

  def set_winner(current_user)
    self.winner = current_user.name
    self.state = 'Finished'
  end

  def set_draw
    self.state = 'Draw'
  end

  def set_turn
    other = self.turn == "X" ? 'O' : 'X'
    self.turn = other
  end

  def set_my_turn(current_user)
    turn = valid_turn?(current_user)
    self.myTurn = turn
  end

  def valid_turn?(current_user)
    symbol = user_symbol(current_user)
    self.turn == symbol
  end

  def valid_place?(index)
    index = index.to_i
    self.table[index] == nil && index >= 0 && index <9
  end

  def can_join?(current_user)
    self.users.include?(current_user) ? false : self.users.count == 1
  end
end
