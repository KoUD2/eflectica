class ErrorsController < ApplicationController
  layout 'errors'

  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end

  def unprocessable_entity
    render status: 422
  end
end 