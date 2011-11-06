# Overview

Look in the auth_controller to see the current playground of code. At some point
soon it will be refactored for prime time business!

We need to create a "sign in" link that opens up janrain_login_url() which will allow the
user to either login or register and then log the user into the site.

We will have links for register and profile as well.

We will need to create a user model that will contain required fields, the
capture_id, and any other data relevant to the user that is site specific, or
that will be loaded into Janrain's capture database.

# User Model

    class User < ActiveRecord::Base
      include Janrain::Capture::User
    end

User capture methods:

    User.find_by_capture_id(7) # => 
    @user = User.find(3) # => internal id that is used for local database
    @user.capture_status
    @user.logged_in?
    @user.refresh_login!

# Controllers

We will need to implement the authentication on controllers so we can ensure that
users are logged in and have permission. 

Simple controller integration:

    class ApplicationController < ActionController::Base
      include Janrain::Auth
    end

Familiar authentication API's:

    class MusicController < ApplicationController
      before_filter :authenticate_user! # just like devise

      def index
        # same methods and api as devise.
        return if logged_in? and current_user.email
      end
    end

Admin permission enforcement:

    class Roadie::MusicController < ApplicationController
      before_filter :authenticate_user! # just like devise
      before_filter :require_admin! # enforce admin permissions
    end

# Url Helpers

Url helpers (used for fancybox/iframed, etc):

    janrain_login_url
    janrain_register_url
    janrain_edit_profile_url(current_user)

# Session mangement

    class AuthController < ApplicationController
      def new
        # goes to a page that opens up the sign in/sign up modal
      end

      def create
        # processes new and existing users and signs them in
      end

      def destroy
        # signs a user out
      end
    end

# configuration 

Simple configuration (config/janrain.yml):

    development:
      capture:
        client_id: 'kjhgkjhgdw7qd8qw873yrgukegw'
        secret: 'sssshh-dont-tell-anyone'
        endpoint: 'https://asite.dev.janraincapture.com'

## Possible Module Organization

Janrain::Capture::User

Janrain::Session

Janrain::UrlHelpers

Janrain::Configuration

# TODO: 

Outside in/ front to back

  * setup artiface, rails app
  * create user from oauth request
  * login user from oauth request
  * update user from oauth request
  * create the authenticated!
    ** setup the authenticated case
    ** setup not authenticated case
  * create the require_admin
    ** setup the authenticated case
    ** setup the not authenticated case
  * create configuration for capture
  * create url helpers
  * create create the sign out case

