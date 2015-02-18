class EmberBookingSyncSetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  class_option :rack_cors_resource, type: :string, required: true
  class_option :after_bookingsync_sign_in_path, type: :string, required: true

  def check_prerequisites
    raise "config/environments/staging.rb not found" unless staging_env_exists?
  end

  def handle_rack_cors_gem
    add_rack_cors_gem_and_bundle unless rack_cors_gem_added?
    add_rack_cors_config unless rack_cors_already_set_up?
  end

  def handle_env_files
    set_up_localui unless localui_env_exists?
    set_up_remoteui unless remoteui_env_exists?
  end

  def handle_application_controller
    set_up_application_controller unless application_controller_set_up?
  end

  def print_powenv_message
    message = <<-MESSAGE

========================================================================================
========================================================================================

To run Ember apps from BookingSync App Store you need to use localui ENV in development.
Add: export RAILS_ENV=localui to .powenv file.

If you are inheriting from JSONAPI::ResourceController you may need to use prepend_before_action :authenticate_account! instead of before_action to ensure current_account is present.

========================================================================================
========================================================================================

MESSAGE
    puts message
  end

  private

  def staging_env_exists?
    env_exists?("staging")
  end

  def rack_cors_gem_added?
    File.open("#{Rails.root}/Gemfile", "r") { |f| f.read.include?("rack-cors") }
  end

  def add_rack_cors_gem_and_bundle
    gem_group :localui, :remoteui do
      gem 'rack-cors', require: 'rack/cors'
    end
    run "bundle install"
  end

  def rack_cors_already_set_up?
    File.open("#{Rails.root}/config/application.rb", "r") { |f| f.read.include?("Rack::Cors") }
  end

  def add_rack_cors_config
    rack_cors_config = <<-CONFIG
  # Necessary to use a remote frontend during UI development.
  if Rails.env.localui? || Rails.env.remoteui?
    config.middleware.insert_before "Rack::Sendfile", "Rack::Cors" do
      allow do
        origins '*'
        resource "#{options[:rack_cors_resource]}",
          headers: :any,
          expose: [],
          methods: [:get, :post, :put, :delete, :options]
      end
    end
  end
  CONFIG
    inject_into_file "config/application.rb", rack_cors_config, before: /^\s\send/
  end

  def set_up_localui
    copy_file "#{Rails.root}/config/environments/development.rb", "config/environments/localui.rb"
    gsub_file("config/environments/localui.rb" , /OmniAuth.+/, "")
    inject_into_file "config/environments/localui.rb", ember_omniauth_full_host, before: /^end/
  end

  def localui_env_exists?
    env_exists?("localui")
  end

  def set_up_remoteui
    copy_file "#{Rails.root}/config/environments/staging.rb", "config/environments/remoteui.rb"
    gsub_file("config/environments/remoteui.rb" , /OmniAuth.+/, "")
    inject_into_file "config/environments/remoteui.rb", ember_omniauth_full_host, before: /^end/
  end

  def remoteui_env_exists?
    env_exists?("remoteui")
  end

  def env_exists?(env)
    File.exists?("#{Rails.root}/config/environments/#{env}.rb")
  end

  def ember_omniauth_full_host
    "\s\sOmniAuth.config.full_host = \"http://0.0.0.0:4200\"\n"
  end

  def set_up_application_controller
    inject_into_file "app/controllers/application_controller.rb", after_booking_sign_in_path_body, before: /^end/
  end

  def application_controller_set_up?
    File.open("#{Rails.root}/app/controllers/application_controller.rb", "r") do |f|
      f.read.include?(after_booking_sign_in_path_body)
    end
  end

  def after_booking_sign_in_path_body
    config =  <<-CONFIG

  def after_bookingsync_sign_in_path
    # Necessary to use a remote frontend during UI development.
    if Rails.env.localui? || Rails.env.remoteui?
      "http://0.0.0.0:4200"
    else
      #{options[:after_bookingsync_sign_in_path]}
    end
  end
  CONFIG
  end
end
