module ApplicationHelper

  # For message partial
  def message_type(type)
    case type
    when 'success'
      'green'
    when 'error'
      'red'
    when 'alert'
      'yellow'
    when 'notice'
      'blue'
    else
      'gray'
    end
  end

  def interest_rate_plus_lenders_fee(deal)
    interest_rate = deal&.terms&.interest_rate || 0
    lenders_fee = deal&.terms&.lenders_fee || 0

    formatted_interest_rate = number_to_percentage(interest_rate, precision: interest_rate % 1 == 0 ? 0 : 1)
    formatted_lenders_fee = number_to_percentage(lenders_fee, precision: lenders_fee % 1 == 0 ? 0 : 1)

    "#{formatted_interest_rate} + #{formatted_lenders_fee}"
  end

  def user_has_unread_notifications
    return current_user.notifications.where(read: false).count > 0 if current_user.present?

    false
  end

  def number_to_currency_without_cents(amount, options = {})
    number_to_currency(amount, precision: 0, unit: "$", format: "%u%n", delimiter: ",")
  end

  def ordinalize_date(string_date)
    return unless string_date.present?

    date = Date.parse(string_date)
    formatted_date = date.strftime("%b #{date.day.ordinalize}, %Y")
    formatted_date
  end

  def iconize(name = "", path = nil)
    return unless name.present?

    base_name = name.underscore.gsub(/[^0-9a-z ]/i, '').gsub(' ', '_')

    if path.present?
      "#{path}/#{base_name}.svg"
    else
      "#{base_name}.svg"
    end
  end

  def blur_style(level = "sm")
    "blur-#{level}" unless user_signed_in?
  end

  def blur_content(content, fake_content = nil)
    if user_signed_in?
      content
    else
      fake_content || t(".please_sign_in")
    end
  end

  def fraud_check_text(status)
    case status.downcase
    when "pass"
      "text-emerald-500"
    when "fail"
      "text-rose-500"
    else
      "text-gray-600"
    end
  end

  def ai_badge(form_object, data = "")
    return unless defined?(@deal)
    return unless Flipper.enabled?(:ai_documents, Current.user)

    ai_data = @deal&.ai_document_pool&.fetch(data)

    if ai_data.present? && ai_data == form_object
      ai_badge_icon
    end
  end

  def ai_badge_collection(collection, data = "")
    return unless defined?(@deal)
    return unless Flipper.enabled?(:ai_documents, Current.user)

    ai_data_collection = @deal&.ai_document_pool&.fetch(data) || []

    collection = collection.respond_to?(:serialize) ? collection.serialize : collection

    any_match_found = collection.any? do |item|
      ai_data_collection.any? do |ai_data|
        item.stringify_keys.any? { |key, value| ai_data[key] == value }
      end
    end

    return ai_badge_icon if any_match_found
  end

  def ai_badge_icon
      content_tag :div, "Levitas AI",
        class: "inline-block rounded-md bg-purple-100 px-2 text-purple-700 font-semibold text-xs"
  end
end
