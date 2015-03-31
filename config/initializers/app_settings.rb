# AppSettings is used an a configuration wrapper. It loads configuration from config/settings.yml and
# create class getters for each of the attributes.
# The values can be retrieved in the code via   AppSettings.config_name (example: AppSettings.ignore_user_agent_locale)
# if a method is called but it is not in the settings.yml, it will just return nil 

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
