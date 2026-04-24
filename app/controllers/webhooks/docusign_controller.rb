class Webhooks::DocusignController < ApplicationController
  protect_from_forgery with: :null_session

  def create

    logger.info params

    case webhook_params[:event]
    when "recipient-completed"
      RecipientCompletedWebhookJob.perform_later(webhook_params[:data])
    end

    render plain: 'OK', status: :ok
  end

  def webhook_params
    params.permit(
      :event,
      :apiVersion,
      :uri,
      :retryCount,
      :configurationId,
      :genereateDateTime,
      data: [:accountId, :userId, :envelopeId, :recipientId]
    )
  end
end
