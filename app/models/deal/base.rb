class Deal::Base
  include ActiveModel::Model

  def safe_serialization
    serialized = serialize

    valid?

    deep_reject(serialized)
  end

  private

  def deep_reject(obj, errors = [])
    case obj
    when Hash
      # Process each key-value pair in the hash
      obj.each_with_object({}) do |(key, value), new_hash|
        filtered_value = deep_reject(value, errors)
        # Include key-value pairs unless the value is nil, empty, or the key is in errors
        unless filtered_value.nil? || (filtered_value.respond_to?(:empty?) && filtered_value.empty?) || errors.include?(key)
          new_hash[key] = filtered_value
        end
      end
    when Array
      obj.map { |item| deep_reject(item, errors) }.reject(&:nil?).reject { |item| item.respond_to?(:empty?) && item.empty? }
    when String
      obj.downcase == 'unknown' ? nil : obj
    else
      obj
    end
  end

  def key_in_errors?(key, errors)
    errors.include?(key)
  end
end
