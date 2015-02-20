# BookingsyncRailsApplicationEmberSetup

Generator for setting up Rails application to work with Ember in BookingSync App Store.

## Usage

Example:

`rails generate ember_booking_sync_setup --rack_cors_resource="/admin/v2" --after-bookingsync-sign-in-path="root_path"`

This will:

- add rack_cors gem to the Gemfile and bundle
- add config to config/application.rb for Rack::Cors
- create localui environment file from development env and add config for OmniAuth
- create remoteui environment file from staging env and add config for OmniAuth
- add after_bookingsync_sign_in_path to ApplicationController
- print message about .powenv

