module Janrain
  module Capture
    module Client; end
  end
end

require 'bitfields'
require 'janrain/config.rb'
require 'janrain/authentication.rb'
require 'janrain/capture/user.rb'
require 'janrain/capture/url_helper.rb'
require 'janrain/capture/client/oauth.rb'
require 'janrain/capture/client/entity.rb'
require 'janrain/capture/client/entity_type.rb'

# load the modules into the rails world
[
  ActionView::Base,
  ActionController::Base
].each { |mod| mod.send :include, Janrain::Capture::UrlHelper }

