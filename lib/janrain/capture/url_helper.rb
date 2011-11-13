module Janrain::Capture::UrlHelper
  extend ActiveSupport::Concern

  # XXX:
  # 1) implement the urls below
  # 2) support return_to
  # 3) make the methods accessible throughout the app

  included do
    # helper_method :url_one_url
  end

  # custom urls go here
  # janrain_signin_url
  # <iframe src="<%= @domain %>/oauth/signin?response_type=code&redirect_uri=http%3A//<%= @host %>/auth&client_id=<%= @client_id %>&xd_receiver=http%3A//<%= @host %>/xdcomm.html" width="500" height='1000'></iframe>
  #
  # janrain_signup_url
  # <iframe src="<%= @domain %>/oauth/legacy_register?response_type=code&redirect_uri=http%3A//<%= @host %>/auth&client_id=<%= @client_id %>&xd_receiver=http%3A//<%= @host %>/xdcomm.html" width="500" height='1000'></iframe>
  #
  # janrain_edit_profile_url(current_user)
  # <iframe src="<%= @domain %>/oauth/profile?access_token=<%= @access_token %>&callback=closeProfileEditor&xd_receiver=http%3A//<%= @host %>/xdcomm.html" width="800" height='1000'></iframe>
  #
  # janrain_signout_url
  # this will just sign them out locally

  protected

  # stuff goes here

end

