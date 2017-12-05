module V1
  class Reports < Grape::API
    include V1Base
    include AuthenticateRequest
    include ReportBase

    VALID_PARAMS = %w(title description owner_id)

    helpers do
      def report_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    resource :reports do

      desc 'Get All Reports', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
        ]
      }
      params do
        optional :page, type: Integer, desc: 'page'
        optional :per_page, type: Integer, desc: 'per_page'
      end
      get :all do
        authenticate!
        can_view_reports?
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || PER_PAGE).to_i
        reports = current_user.last_month_closed_tickets.order("closed_at DESC").page(page).per(per_page)
        serialization = ActiveModel::Serializer::CollectionSerializer.new(reports, each_serializer: TicketSerializer)
        render_success(serialization.as_json , pagination_dict(reports).merge({download_link: "#{ENV.fetch('BASE_URL')}/reports.pdf?token=#{current_user.user_tokens.first.token}"}))
      end

    end
  end
end

