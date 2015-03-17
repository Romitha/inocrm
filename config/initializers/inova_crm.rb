variables = File.join Rails.root, "config", "data_config.yml"

INOCRM_CONFIG = YAML.load File.read(variables)