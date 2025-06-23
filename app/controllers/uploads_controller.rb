class UploadsController < ApplicationController
  before_action :set_cors_headers
  skip_before_action :verify_authenticity_token

  def show
    file_path = Rails.root.join('public', 'uploads', params[:path])
    
    if File.exist?(file_path)
      send_file file_path, disposition: 'inline'
    else
      head :not_found
    end
  end

  private

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS, HEAD'
    response.headers['Access-Control-Allow-Headers'] = '*'
  end
end 