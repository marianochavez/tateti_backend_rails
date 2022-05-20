class Board < ApplicationRecord

  has_and_belongs_to_many :users, join_table: 'users_boards'

  serialize :table #save an object

  def initialize_board(current_user)
    self.table = [nil]*9
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
    index = index.to_i
    self.table[index] = turn
  end

  def valid_place?(index)
    index = index.to_i
    self.table[index] == nil && index >= 0 && index <9
  end

  def winner?(current_user)
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
    turn = user_symbol(current_user)

    winning_position.length.times do |i|
      a,b,c = winning_position[i]
      if self.table[a] && self.table[a] == self.table[b] && self.table[a] == self.table[c]
        return self.table[a] == turn
      end
    end
    nil
  end

  def draw?
    !winner && self.table.map.select{|item| !item}.length == 0
  end

  def set_winner(current_user)
    self.winner = current_user.name
    self.state = 'Finished'
  end

  def set_draw
    self.state = 'Draw'
    self.winner = 'Empate'
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

  def can_join?(current_user)
    self.users.include?(current_user) ? false : self.users.count == 1
  end
end
