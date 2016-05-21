class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  helper_method :resource, :resource_name, :devise_mapping

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:first_name, :email, :password, :password_confirmation, :last_name)
    end

    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit! #(:first_name,:current_password,  :email, :password, :password_confirmation,:last_name,:country,:address, :bio, :city, :estate, :image, :category_id,:profile_pictures_attributes, :sub_category_id)
    end

    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit(:email, :password)
    end
  end

  def after_sign_in_path_for(resource)
    nex_path = resource.subscription.present? ? profile_path : new_subscription_path
    request.env['omniauth.origin'] || stored_location_for(resource) || nex_path
  end

  def subscribed_user
    return false unless current_user.present?
    if current_user.subscription.present?
      true
    else
      redirect_to new_subscription_path
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
