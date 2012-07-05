module Janrain::Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?, :sign_in, :sign_out!
  end

  def current_user
    @current_user ||= Janrain::Config.model.find_by_id(session[:session_user]) if session[:session_user]
    @current_user = @current_user.refresh_authentication! if @current_user and @current_user.expired?
    @current_user
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

  # Override this method in controller for custom javascript stuff
  def render_js_redirect(url)
    render text: "<script>parent.location = '#{url}';</script>"
  end

  def original_or_default_url(default)
    url = (session[:origin] || params[:origin] || default)
    session[:origin] = nil
    url
  end

  def render_or_redirect(default)
    url = original_or_default_url(default)
    if Janrain::Config.within_iframe?
      render_js_redirect(url)
    else
      redirect_to url
    end
  end

  def authenticate_user!
    access_denied unless user_signed_in?
  end

  def authenticate_admin_user!
    access_denied unless user_signed_in? and current_user.admin?
  end

  def authenticate_super_user!
    access_denied unless user_signed_in? and current_user.admin? and current_user.superuser?
  end

  def access_denied
    session[:origin] = request.url
    redirect_to send("new_janrain_#{Janrain::Config.controller.to_s.downcase}_url"), flash: { error: 'The page you requested requires you to be signed in' }
  end

end
