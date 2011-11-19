module Janrain::Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?, :sign_in, :sign_out!
  end

  def current_user
    @current_user ||= Janrain::Config.model.find_by_id(session[:session_user]) if session[:session_user]
  end

  def user_signed_in?
    !!current_user
  end
  alias_method :signed_in?, :user_signed_in?

  def sign_in user
    session[:session_user] = user.try(:id)
    current_user
  end

  def sign_out!
    session[:session_user] = nil
    @current_user = nil
  end

  protected

  def original_or_default_url(default)
    url = (session[:return_to] || params[:return_to] || default)
    session[:return_to] = nil
    url
  end

  def authenticate_user!
    unless user_signed_in?
      session[:return_to] = request.url
      redirect_to send("new_janrain_#{Janrain::Config.controller.to_s.downcase}_url"), flash: { error: 'The page you requested requires you to be signed in' }
    end
  end

end
