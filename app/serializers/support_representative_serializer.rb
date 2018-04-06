class SupportRepresentativeSerializer < UserSerializer
  attribute :ticket_count

  def ticket_count
    object.tickets.count
  end

end
