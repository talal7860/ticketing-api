class Customer < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable, :recoverable, :validatable
  has_many :tickets, dependent: :destroy, foreign_key: :owner_id
  has_many :messages, through: :tickets, foreign_key: :sender_id
end
