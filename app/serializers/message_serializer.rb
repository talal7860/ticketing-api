class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :ticket, :sender
  belongs_to :sender
  belongs_to :ticket

end


