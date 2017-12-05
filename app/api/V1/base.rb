require "grape-swagger"
module V1
  class Base < Grape::API
    mount V1::Sessions
    mount V1::Users
    mount V1::SupportRepresentatives
    mount V1::Customers
    mount V1::Tickets
    mount V1::Reports
    mount V1::Ticket::Messages

    add_swagger_documentation(
      api_version: "v1",
      hide_documentation_path: true,
      mount_path: "/api/v1/docs",
      hide_format: true,
      info: {
        title: "Customer Support Ticketing System",
        description: "A description of the API."
      }
    )
  end
end
