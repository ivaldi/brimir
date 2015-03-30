class AppSettings
  def self.load
    config_file = File.join(Rails.root, "config", "settings.yml")
    
    if File.exists?(config_file)
      config = YAML.load(File.read(config_file))[Rails.env]
      config.keys.reject { |k| k == "<<" }.each do |key|
        cattr_accessor key
        send("#{key}=", config[key])
      end
    end
  end

  def self.method_missing(*)
    nil
  end
end
AppSettings.load
