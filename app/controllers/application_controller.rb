class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :prepare_meta_tags, if: 'request.get?'
  helper_method :resource, :resource_name, :devise_mapping

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :email, :password, :password_confirmation, :last_name)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit! #(:first_name,:current_password,  :email, :password, :password_confirmation,:last_name,:country,:address, :bio, :city, :estate, :image, :category_id,:profile_pictures_attributes, :sub_category_id)
    end

    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password)
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      stored_location_for(resource) || admin_dashboard_path
    elsif resource.is_a?(User)
      next_path = resource.subscription.present? ? profile_path : new_subscription_path
      request.env['omniauth.origin'] || stored_location_for(resource) || next_path
    end

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

  private

  def prepare_meta_tags(options={})
    site_name = 'New Artist Release'
    title = options[:title] || [controller_name, action_name].join(' ')
    description = options[:description] || 'Since 2000, musical artists, models, and book authors worldwide have relied on New Artist Release to promote their talent to the world'
    image = options[:image] || 'logo.png'
    current_url = request.url

    # Let's prepare a nice set of defaults
    defaults = {
        site: site_name,
        title: title,
        image: image,
        description: description,
        keywords: %w[web software development mobile app],
        twitter: {
            site_name: site_name,
            site: '@NAR',
            card: 'summary',
            description: description,
            image: ActionController::Base.helpers.image_url(image),
        },
        og: {
            url: current_url,
            site_name: site_name,
            title: title,
            image: ActionController::Base.helpers.image_url(image),
            description: description,
            type: 'website'
        }
    }
    options.reverse_merge!(defaults)
    set_meta_tags options
  end

end
