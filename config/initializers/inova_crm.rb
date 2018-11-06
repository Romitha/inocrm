variables = File.join Rails.root, "config", "#{Rails.env}_data_config.yml"

INOCRM_CONFIG ||= YAML.load File.read(variables)