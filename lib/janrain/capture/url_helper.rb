module Janrain::Capture::UrlHelper
  extend ActiveSupport::Concern

  included do
    if self.respond_to? :helper_method
      helper_method :janrain_signin_url, :janrain_signup_url, :janrain_edit_profile_url
    end
  end

  def janrain_signin_url(options={})
    "#{capture_config.domain}/oauth/signin?response_type=code&redirect_uri=#{janrain_redirect_url(options)}&client_id=#{capture_config.client_id}&xd_receiver=http%3A//#{request.host}/xdcomm.html"
  end

  def janrain_signup_url(options={})
    "#{capture_config.domain}/oauth/legacy_register?response_type=code&redirect_uri=#{janrain_redirect_url(options)}&client_id=#{capture_config.client_id}&xd_receiver=http%3A//#{request.host}/xdcomm.html"
  end

  def janrain_edit_profile_url(user)
    "#{capture_config.domain}/oauth/profile?access_token=#{user.try(:access_token)}&callback=closeProfileEditor&xd_receiver=http%3A//#{request.host}/xdcomm.html"
  end

  private

  def janrain_redirect_url(options={})
    CGI.escape(Janrain::Config.redirect_url({host:request.host}.merge(options)))
  end

  def capture_config
    Janrain::Config.capture
  end

end

