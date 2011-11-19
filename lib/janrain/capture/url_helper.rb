module Janrain::Capture::UrlHelper
  extend ActiveSupport::Concern

  # XXX: support return_to as a parameter on the redirect_url

  included do
    if self.respond_to? :helper_method
      helper_method :janrain_signin_url
    end
  end

  def janrain_signin_url(options={})
    config = Janrain::Config.capture
    "#{config.domain}/oauth/signin?response_type=code&redirect_uri=#{CGI.escape(config.redirect_url)}&client_id=#{config.client_id}&xd_receiver=http%3A//#{request.host}/xdcomm.html"
  end

  def janrain_signup_url(options={})
    config = Janrain::Config.capture
    "#{config.domain}/oauth/legacy_register?response_type=code&redirect_uri=#{CGI.escape(config.redirect_url)}&client_id=#{config.client_id}&xd_receiver=http%3A//#{request.host}/xdcomm.html"
  end

  def janrain_edit_profile_url(user)
    config = Janrain::Config.capture
    "#{config.domain}/oauth/profile?access_token=#{user.try(:access_token)}&callback=closeProfileEditor&xd_receiver=http%3A//#{request.host}/xdcomm.html"
  end

  private

  # def current_host
  #  "http://#{request.host}#{config.redirect_url}"
  # end

end

