class Ticket < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :assigned_to, class_name: 'SupportRepresentative', optional: true
  validates :title, :description, presence: true
  has_many :messages
  before_save :set_closed_date

  enum status: [
    :open,
    :assigned,
    :closed
  ]

  def assign_support_representative(support_representative)
    self.update(status: 'assigned', assigned_to: support_representative)
  end

  def resolve
    if status === 'assigned' && assigned_to_id.present?
      self.update(status: 'closed')
    else
      self.errors.add(:this, 'ticket has not been assigned to anyone')
    end
  end

  private

  def set_closed_date
    if status == 'closed' && closed_at.nil?
      closed_at = Time.now
    end
  end
end
