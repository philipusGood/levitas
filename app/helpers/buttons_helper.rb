module ButtonsHelper
  def levitas_button(type, text, variant = "", disabled = false, size = :regular)
    valid_type? type

    @base_class = "levitas-button"
    @base_class << " #{size}" if valid_size? size

    return primary_button(type, text, disabled) if variant.eql? "primary"
    return danger_button(type, text, disabled) if variant.eql? "danger"
    return critical_button(type, text, disabled) if variant.eql? "critical"

    button_tag type: type, disabled: disabled, class: @base_class do
      content_tag :span, text
    end
  end

  private

  def valid_size?(size)
    sizes = [:regular, :large, :wide]
    unless sizes.include? size
      raise ArgumentError, "Invalid button size provided. Allowed sizes are #{sizes.join(', ')}"
    end
    true
  end

  def valid_type?(type)
    valid_types = [:button, :submit, :reset]
    unless valid_types.include? type
      raise ArgumentError, "Invalid button type provided. Allowed types are #{valid_types.join(', ')}"
    end
  end

  def primary_button(type, text, disabled)
    button_tag type: type, disabled: disabled, class: @base_class << " primary" do
      content_tag :span, text
    end
  end

  def danger_button(type, text, disabled)
    button_tag type: type, disabled: disabled, class: @base_class << " danger" do
      content_tag :span, text
    end
  end

  def critical_button(type, text, disabled)
    button_tag type: type, disabled: disabled, class: @base_class << " critical" do
      content_tag :span, text
    end
  end
end
