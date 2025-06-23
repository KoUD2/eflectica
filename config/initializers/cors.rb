Rails.application.config.middleware.use Rack::Static, 
  urls: ['/uploads'], 
  root: 'public',
  header_rules: [
    ['/uploads', { 'Access-Control-Allow-Origin' => '*' }]
  ] 