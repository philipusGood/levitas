class Deals::DocumentsController < Deals::BaseController
  skip_before_action :verify_state, except: [:index]

  before_action :verify_ai_document_pool, if: :ai_documents_enabled?

  def index
  end

  def edit
    @document = @deal.documents.find(params[:id])

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update
    @document = @deal.documents.find(params[:id])

    document = @deal.documents.find(params[:id])
    metadata = document.blob.metadata
    metadata[:filename] = params[:filename] if params[:filename].present?
    document.blob.update(metadata: metadata)

    render turbo_stream: turbo_stream.replace("document_#{document.id}", partial: 'deals/documents/document', locals: { document: document })
  end

  def upload
    if params[:blob].present?
      @deal.documents.attach(params[:blob])
      @deal.save

      PosthogEventJob.perform_async('Upload Documents to Deal', current_user.email, {
        'role' => current_user.role,
        'deal_id' => @deal.id,
        'deal_name' => @deal.name
      })

      render turbo_stream: turbo_stream.append("documents", partial: 'deals/documents/document', locals: { document: @deal.documents.last })
    elsif Flipper.enabled?(:ai_documents, Current.user) && @deal.documents.count > 0
      @deal.analize_documents!
      redirect_to deal_documents_path(@deal)
    else
      redirect_to deal_broker_fee_index_path(@deal)
    end
  end

  def upload_ai
    if params[:blob].present?
      @deal.documents.attach(params[:blob])
      @deal.save

      PosthogEventJob.perform_async('Upload Documents to Deal', current_user.email, {
        'role' => current_user.role,
        'deal_id' => @deal.id,
        'deal_name' => @deal.name
      })

      render turbo_stream: turbo_stream.append("documents", partial: 'deals/documents/document', locals: { document: @deal.documents.last })
    elsif @deal.documents.count > 0
      @deal.analize_documents!
      redirect_to deal_documents_path(@deal)
    else
      redirect_to deal_main_applicant_index_path(@deal)
    end
  end

  def destroy
    document = @deal.documents.find(params[:id])
    document.destroy

    render turbo_stream: turbo_stream.remove("document_attachment_#{document.id}")
  end

  def change_visibility
    document = @deal.documents.find(params[:id])
    metadata = document.blob.metadata
    metadata[:private] = !metadata[:private]
    document.blob.update(metadata: metadata)

    render turbo_stream: turbo_stream.replace("document_#{document.id}", partial: 'deals/documents/document', locals: { document: document })
  end

  def download
    document = @deal.documents.find(params[:id])
    send_data document.blob.download, filename: document.blob.filename.to_s, type: document.blob.content_type
  end

  private
  def next_step_path
    deal_broker_fee_index_path(@deal)
  end

  def set_active_step
    @active_step = @step_builder.set_current_step(:documents)
  end

  def ai_documents_enabled?
    Flipper.enabled?(:ai_documents, Current.user)
  end

  def verify_ai_document_pool
    if @deal.ai_document_pool.present? && @deal.ai_document_pool.status == AiDocumentPool::PREFILLED && !@deal.ai_document_pool.has_inconsistencies?
      redirect_to deal_main_applicant_index_path(@deal)
    end
  end
end
