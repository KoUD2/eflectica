SERVICES = YAML.load_file(Rails.root.join("config/services/app.yml"))["services"]
DEVICES = YAML.load_file(Rails.root.join("config/services/devices.yml"))["devices"]