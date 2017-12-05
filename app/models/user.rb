class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :validatable, :trackable

  ## Relationship
  has_many :user_tokens, dependent: :destroy

  ## Validations
  validates :email, presence: true, uniqueness: true, case_sensitive: false
  validates :first_name, :last_name, presence: true

  ## Callbacks
  before_save do
    self.email = email.downcase if email_changed?
  end

  ## Methods
  def self.by_auth_token(token)
    user_token = UserToken.where(token: token).first
    user_token ? user_token.user : nil
  end

  def name
    "#{first_name} #{last_name}"
  end

  def login!
    self.user_tokens.create
  end

  def admin?
    type == 'Admin'
  end

  def customer?
    type == 'Customer'
  end

  def support_representative?
    type == 'SupportRepresentative'
  end

  def can_manage_ticket?(ticket)
    return true if admin?
    return true if customer? && id == ticket.owner_id
    return can_work_on_ticket?(ticket)
  end

  def can_delete_ticket?(ticket)
    return true if admin?
    return true if customer? && id == ticket.owner_id
  end

  def can_work_on_ticket?(ticket)
    return true if support_representative? && (ticket.assigned_to_id.nil? || id == ticket.assigned_to_id)
  end

  def can_resolve_ticket?(ticket)
    return true if support_representative? && id == ticket.assigned_to_id
  end

  def can_post_message_to_ticket?(ticket)
    return false if ticket.status == 'closed'
    can_see_messages_for_ticket?(ticket)
  end

  def can_see_messages_for_ticket?(ticket)
    return true if admin?
    return true if customer? && (ticket.owner_id == id)
    return true if support_representative? && (ticket.assigned_to_id == id)
  end

  def can_view_reports?
    admin? || support_representative?
  end

  def last_month_closed_tickets
    if can_view_reports?
      tickets.where('status = ? AND closed_at > ? AND closed_at < ?', Ticket.statuses[:closed] , 1.month.ago.beginning_of_month, Date.today.beginning_of_month)
    end
  end

end
