class Board < ApplicationRecord

  has_many :users

  validates :user_1, presence: true

  before_create :set_init_table

  enum state: { Queue: 0, Playing: 1, Finished: 2, Draw: 3, Abandoned: 4 }

  serialize :table

  include Filterable
  scope :filter_by_state, -> (state) { where state: state }
  scope :filter_by_user_1, -> (user_1) { where user_1: user_1 }
  scope :filter_by_user_2, -> (user_2) { where user_2: user_2 }

  def set_init_table
    self.table = [nil] * 9
  end

  def create_game(user)
    self.user_1 = user
  end

  def join_game(user)
    self.user_2 = user
    self.state = 1
    self.turn = rand(2) == 0 ? user_1 : user_2
  end

  def can_play?(user)
    unless !user_2.present? || user == turn
      return false
    end

    true
  end

  def user_symbol(user)
    user == user_1 ? 'X' : 'O'
  end

  def play(index, user)
    insert_in(index)
    if winner?(user)
      set_winner(user)
      set_state(2)
    else
      if draw?
        set_draw
      else
        set_turn
      end
    end
  end

  def insert_in(index)
    index = index.to_i
    self.table[index] = user_symbol(turn)
  end

  def valid_place?(index)
    index = index.to_i
    table[index] == nil && index >= 0 && index < 9
  end

  def winner?(user)
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
    turn = user_symbol(user)

    winning_position.length.times do |i|
      a, b, c = winning_position[i]
      if self.table[a] && self.table[a] == self.table[b] && self.table[a] == self.table[c]
        return self.table[a] == turn
      end
    end
    nil
  end

  def draw?
    !winner && self.table.map.select { |item| !item }.length == 0
  end

  def set_winner(user)
    self.winner = user
  end

  def set_draw
    self.state = 3
    self.winner = 'Empate'
  end

  def set_turn
    other = self.turn == user_1 ? user_2 : user_1
    self.turn = other
  end

  def can_join?(user)
    (user_1 == user || user_2 == user) ? false : !user_2.present?
  end

  def can_leave?(user)
    user == user_1 || user == user_2
  end

  def set_state(index)
    self.state = index
  end

end
