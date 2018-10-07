namespace :locales do

  desc "Check locale files for completeness."
  task :completeness => :environment do
    base_file = "#{I18n.default_locale}.yml"
    puts "Diffing against default locale files (#{base_file})."
    results = ''
    Dir.glob("**/#{base_file}").each do |file_1|
      (I18n.available_locales - [I18n.default_locale]).each do |locale_2|
        file_2 = file_1.sub(/#{base_file}$/, "#{locale_2}.yml")
        unless File.exists? file_1
          warn "WARNING: `#{file_1}' does not exist"
          next
        end
        if (yaml_1 = YAML.load_file(file_1)) == false
          warn "WARNING: `#{file_1}' does not contain valid YAML"
          next
        end
        unless File.exists? file_2
          warn "WARNING: `#{file_2}' does not exist"
          next
        end
        if (yaml_2 = YAML.load_file(file_2)) == false
          warn "WARNING: `#{file_2}' does not contain valid YAML"
          next
        end
        keys_1 = flatten_keys(yaml_1[yaml_1.keys.first])
        keys_2 = flatten_keys(yaml_2[yaml_2.keys.first])
        different_keys = (keys_1 - keys_2).map { |k| "  - #{k}" } + (keys_2 - keys_1).map { |k| "  + #{k}" }
        results += %Q(--- #{file_1}\n+++ #{file_2}\n#{different_keys.join("\n")}\n\n) if different_keys.any?
      end
    end
    if results.present?
      puts "\n#{results.chomp}"
    else
      puts "All locales are complete."
    end
  end

  def flatten_keys(hash, prefix="")
    keys = []
    hash.keys.each do |key|
      if hash[key].is_a? Hash
        current_prefix = prefix + "#{key}."
        keys << flatten_keys(hash[key], current_prefix)
      else
        keys << "#{prefix}#{key}"
      end
    end
    prefix == "" ? keys.flatten : keys
  end

end
