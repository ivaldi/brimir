class AppSettings
  def self.load
    config_file = File.join(Rails.root, "config", "settings.yml")
    
    if File.exists?(config_file)
      all_config = YAML.load(File.read(config_file)) 
      config = {}
      ["default", Rails.env].each do |group|
        config.merge!(all_config[group]) unless all_config[group].blank?
      end

      config.keys.reject{|k| k=="<<"}.each do |key|
        cattr_accessor key
        send("#{key}=", config[key])
      end
    end
  end

  def self.method_missing(*args)
    nil
  end
end
AppSettings.load

