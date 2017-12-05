class Message < ApplicationRecord
  belongs_to :ticket
  belongs_to :sender, class_name: 'User'
end
