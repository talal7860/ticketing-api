class Admin < User

  def tickets
    Ticket.all
  end

  def messages
    Message.all
  end

  def invite(params)
    sr = SupportRepresentative.new(params)
    password = Devise.friendly_token.first(8)
    sr.password = password
    sr.password_confirmation = password
    sr.invitation_created_at = Time.now
    sr.invited_by_id = self.id
    sr.invitation_token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless SupportRepresentative.exists?(invitation_token: random_token)
    end
    sr.save
    unless sr.errors.any?
      UserMailer.invite_user(sr).deliver
      sr.invitation_sent_at = Time.now
      sr.save
    end
    sr
  end

end
