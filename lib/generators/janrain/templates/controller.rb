class <%= controller_name.camelize %>Controller < ApplicationController
  def new
  end

  def create
    # XXX: features to add:
    # 1) code auth with render close fancybox
    if @<%= singular_name %> = <%= class_name %>.authenticate(params[:code])
      sign_in @<%= singular_name %>
      flash[:notice] = 'You are now signed in'
    else
      flash[:error] = 'Unable to sign you in, try again'
    end
    render_or_redirect(root_url)
  end

  def destroy
    sign_out!
    flash[:notice] = 'You are now signed out'
    redirect_to original_or_default_url(root_url)
  end
end
