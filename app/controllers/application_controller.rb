class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :user_sign_in?

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_sign_in?
    current_user.present?
  end

  def authenticate_user!
    authenticate_permission { user_sign_in? }
  end

  def authenticate_permission(&block)
    redirect_to root_path unless block.call
  end
end
