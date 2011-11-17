module Janrain::Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?, :sign_in, :sign_out!
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

  def current_user
    # XXX: resource_name
    $stdout.puts "$" * 50
    $stdout.puts "session: #{session.inspect}"
    $stdout.puts "session: #{request.session.inspect}"
    $stdout.puts Janrain::Config.model.find_by_id(request.session[:session_user])
    $stdout.puts "$" * 50
    @current_user ||= Janrain::Config.model.find_by_id(request.session[:session_user]) if request.session[:session_user]
  end

  protected

  def authenticate_user!
    unless user_signed_in?
      # XXX: resource_name
      redirect_to send("new_janrain_#{Janrain::Config.controller.to_s.downcase}_url"), flash: { error: 'The page you requested requires you to be signed in' }
    end
  end

end
