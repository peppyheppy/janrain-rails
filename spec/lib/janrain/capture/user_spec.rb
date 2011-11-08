require 'spec_helper'

class User < ActiveRecord::Base
  include Janrain::Capture::User
end

describe User do
  it "should work" do
    User.new(display_name: 'hello')
  end
end
