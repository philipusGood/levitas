# lib/tasks/translate.rake
namespace :locale do
  desc "Translate English locale file to French"
  task translate_to_french: :environment do
    TranslateLocale.translate_file
  end
end
  