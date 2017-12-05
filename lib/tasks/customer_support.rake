require 'factory_bot_rails'
require 'faker'

namespace :customer_support do
  desc "TODO"
  task create_dummy_data: :environment do
    #create support representatives

    support_representative = FactoryBot.create_list(:support_representative, 10)
    puts "Support Representatives created"
    tickets = FactoryBot.create_list(:ticket, 10)

    puts "Tickets Created"
    tickets.each do |ticket|
      FactoryBot.create_list(:message, 10, ticket_id: ticket.id)
    end
    puts "Messages created"

    support_representative.each do |sr|
      tickets = FactoryBot.create_list(:ticket, 10, assigned_to: sr, status: 'closed', closed_at: 1.month.ago)
    end
    puts "closed tickets created"

  end
end
