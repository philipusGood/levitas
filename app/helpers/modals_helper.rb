module ModalsHelper
  def levitas_modal(template = "")
    return render partial: "/partials/modals/base" if template.empty?
    render partial: "/partials/modals/" << template
  rescue ActionView::MissingTemplate
    render partial: '/partials/modals/base'
  end
end
