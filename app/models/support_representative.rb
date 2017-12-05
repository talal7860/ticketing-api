class SupportRepresentative < User

  def tickets
    Ticket.where('assigned_to_id = ? OR assigned_to_id is NULL', self.id)
  end

  def messages
    Message.where(ticket_id: tickets.ids)
  end

  def self.accept_invitation(params, invitation_token)
   user = self.find_by_invitation_token(invitation_token)
   if user
     user.password = params[:password]
     user.password_confirmation = params[:password_confirmation]
     user.invitation_accepted_at = Time.now
     user.invitation_token = nil
     user.update(params)
   end
   user
  end
end
