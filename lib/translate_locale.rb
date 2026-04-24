# lib/translate_locale.rb
require 'yaml'
require 'typhoeus'
require 'dotenv/load'
require 'json'

module TranslateLocale
  class << self
    def translate_file
      input_path = 'config/locales/defaults.en.yml'
      output_path = 'config/locales/fr.yml'

      data = YAML.load_file(input_path)
      translated_data = translate_data(data)
      File.open(output_path, 'w') { |file| file.write(translated_data.to_yaml) }

      puts "Translation completed: #{output_path}"
    end

    private

    def translate_data(data)
      data.each_with_object({}) do |(key, value), result|
        result[key] = value.is_a?(Hash) ? translate_data(value) : translate_string(value)
      end
    end

    def translate_string(text)
      response = Typhoeus.post(
        "https://api.openai.com/v1/chat/completions",
        headers: {
          'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}",
          'Content-Type' => 'application/json'
        },
        body: {
          model: "gpt-4-0125-preview",
          messages: [{"role": "user", "content": "You are an expert UI Translator. 
                                                  You are going to translate this texts from english to french for this canadian mortgage finance app. 
                                                  You will generate only the translation without commentary or explanations and without being within 
                                                  quotes or any other unneeded special character. Translate this English text to French: '#{text}'"}],
          max_tokens: 60,
          temperature: 0.1
        }.to_json
      )

      if response.success?
        JSON.parse(response.body)['choices'].first['message']['content'].strip
      else
        puts "Error in translation API: #{response.body}"
        text
      end
    end
  end
end
