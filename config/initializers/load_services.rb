SERVICES = YAML.load_file(Rails.root.join("config/services/app.yml"))["services"]
PLATFORM = YAML.load_file(Rails.root.join("config/services/devices.yml"))["devices"]