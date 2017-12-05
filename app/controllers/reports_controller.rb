class ReportsController < ApplicationController
  before_action :authenticate_user

  def index
    @tickets = @user.last_month_closed_tickets
    @from = 1.month.ago.beginning_of_month
    @to = 1.month.ago.end_of_month
    @title = "Tickets closed from #{@from.to_s(:y_m_d)} to #{@to.to_s(:y_m_d)}"
    respond_to do |format|
      format.pdf do
        render pdf: "tickets-closed-#{@from.to_s(:y_m_d)}-to-#{@to.to_s(:y_m_d)}"'file_name.pdf',
          disposition: 'attachment', # default 'inline'
          template: 'reports/index.pdf.erb',
          layout: 'pdf' #for a pdf.pdf.erb file
      end
    end
  end

  private

  def authenticate_user
    @user = User.by_auth_token(params[:token])
    raise ActiveRecord::RecordNotFound unless @user || @user.can_view_reports?
  end
end
