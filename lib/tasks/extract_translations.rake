# lib/tasks/extract_translations.rake
require 'yaml'
require 'haml'


namespace :translations do
  desc "Extract translations from HAML views"
  task :extract => :environment do
    translations = Hash.new { |h, k| h[k] = {} }

    Dir.glob(Rails.root.join('app', 'views', '**', '*.haml')).each do |file_path|
      # Parse HAML file
      haml_content = File.read(file_path)
      # Extract translation keys
      translation_keys = haml_content.scan(/t\(['"](\.[^\)]+)['"]\)/).flatten
      views_path = file_path.split("views/").last

      keys = views_path.split('/').reject(&:empty?)
      controller_action = keys.last.gsub('.html', "").gsub(".haml", "")
      keys.pop
      # Remove the first underscore from controller_action if it exists
      controller_action.sub!(/^_/, '') if controller_action.include?('_')
      basename = File.basename(controller_action, ".*")
      controller_name = basename

      translation_path = []
      translation_path << keys
      translation_path << controller_name
      translation_path.flatten!

      # Building YAML hash

      translation_keys.each do |key|
        result_hash = {}
        translation_path.reverse_each do |element|
          result_hash = { element => result_hash }
        end


        translation_path.inject(result_hash, :fetch)[key.gsub(".", "")] = if I18n.exists?("#{translation_path.join('.')}#{key}")
          I18n.t("#{translation_path.join('.')}#{key}")
        else
          key.gsub(".", "").gsub("_", " ").titleize
        end
        translations.deep_merge!(result_hash)
      end
    end

    # Write translations to YAML file
    File.open(Rails.root.join('config', 'locales', 'extracted_translations.yml'), 'w') do |file|
      file.write(translations.to_yaml)
    end

    puts "Translations extracted and saved to extracted_translations.yml"
  end
end
