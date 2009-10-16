require 'sweepy/config'
require 'sweepy/commander'
require  'sweepy/action_controller'
ActionController::Base.send :include, Sweepy::ActionController
