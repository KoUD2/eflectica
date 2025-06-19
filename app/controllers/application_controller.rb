class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.

  # Handle exceptions in production
  unless Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
  end

  def after_sign_in_path_for(resource)
    effects_path
  end

  def after_sign_up_path_for(resource)
    effects_path
  end

  allow_browser versions: :modern

  private

  def render_404
    redirect_to "/404"
  end
end
