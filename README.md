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

    User#find_by_capture_id(7) # => 
    User#find(3) # => internal id that is used for local database
    User#signed_in? # => TODO
    User#capture_status # => TODO
    User#refresh_login! # => TODO

Local User model properties:

    User#id # => the local active record id used for relations
    User#capture_id # => the capture id used for mapping local records with Janrain
    User#any_local_field # => a local field that is not shared accross federated apps
    User#display_name # => a local cache for the capture value that will be updated on each profile request.

# Controllers

We will need to implement the authentication on controllers so we can ensure that
users are logged in and have permission.

Simple controller integration:

    class ApplicationController < ActionController::Base
      include Janrain::Authentication
    end

Familiar authentication API's:

    class MusicController < ApplicationController
      before_filter :authenticate_user! # just like devise

      def index
        # same methods and api as devise.
        return if signed_in? and current_user.email
      end
    end

Admin permission enforcement:

    class Roadie::MusicController < ApplicationController
      before_filter :authenticate_user! # just like devise
      before_filter :authenticate_admin_user! # enforce admin permissions
      before_filter :authenticate_super_user! # enforce super user permissions
    end

# Url Helpers

Url helpers (used for fancybox/iframes, etc):

    janrain_signin_url
    janrain_signout_url
    janrain_signup_url
    janrain_edit_profile_url(current_user)

Options: :url overrides the return_to url, :host  overrides the host

# Session mangement

    class AuthController < ApplicationController
      def new
        # show a page that has buttons to signup or sign in, etc
      end

      def create
        # processes new and existing users and signs them in
        ...
        sign_in user
      end

      def destroy
        # signs a user out
        sign_out!
      end
    end

# configuration 

Simple configuration (config/janrain.yml):

    development:
      capture:
        client_id: 'kjhgkjhgdw7qd8qw873yrgukegw'
        secret: 'sssshh-dont-tell-anyone'
        domain: 'https://asite.dev.janraincapture.com'

## Possible Module Organization

Janrain::Capture::Client::OAuth
Janrain::Capture::Client::Entity
Janrain::Capture::User
Janrain::Capture::UrlHelpers
Janrain::Config
Janrain::Authentication

# TODO: 

  * add flag for capture update failures, etc
  * save the janrain entity attributes in model as cache @user.some_field
  * create configuration for capture (split out resource/application configs from environment keys and secrets, etc) "resource_name"
  * capture status for model (contains time left, etc)
  * [implement pending tests] create schema tools for adding and removing fields to schema (needs tests)
    * get schema (needs test)
    * create new entity type (user_3, etc)
    * permissions for schema access (ignore for now)
    * add constraints to schema (email, unique constraint)
    * [remove attribute](https://janraincapture.com/docs/api_entityType.removeAttribute.html) (needs tests)
  * add support for default entity types/names for user, etc


# Janrain Documentation

  * [Integration Guide](https://janraincapture.com/docs/integration_guide.html)
  * [API Documentation](https://janraincapture.com/docs/)

