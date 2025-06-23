require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Efex2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.default_locale = :ru
    
    # CORS configuration for uploaded files
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'localhost:3000', '127.0.0.1:3000', 'http://localhost:3000', 'http://127.0.0.1:3000'
        resource '/uploads/*', 
          headers: :any, 
          methods: [:get, :options, :head],
          credentials: false
      end
    end
  end
end
