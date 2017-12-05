class TicketSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :owner, :assigned_to, :status, :closed_at, :created_at
  belongs_to :owner
  belongs_to :assigned_to

  def closed_at
    object.closed_at.to_s(:short) if object.closed_at.present?
  end

  def created_at
    object.created_at.to_s(:short)
  end

end

