class User < ApplicationRecord

  has_and_belongs_to_many :boards, join_table: 'users_boards'

  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
  validates :token, uniqueness: true


  before_create :generate_token

  def generate_token
    self.token = SecureRandom.uuid
  end

end
