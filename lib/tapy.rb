# frozen_string_literal: true

require 'vorx'
require 'dry/cli'
require 'dry/events/publisher'

require 'tapy/version'
require 'tapy/errors'
require 'tapy/arg_options'
require 'tapy/utils'
require 'tapy/recipe_store'
require 'tapy/recipe'
require 'tapy/listeners/log_handler'

module Tapy
  class Events
    include Dry::Events::Publisher[:tapy]

    register_event('tapy.error')
    register_event('recipes.starting')
    register_event('recipes.missing')
    register_event('recipes.installing')
    register_event('recipes.installed')
    register_event('recipes.uninstalling')
    register_event('recipes.uninstalled')
    register_event('recipes.updating')
    register_event('recipes.updated')
    register_event('recipes.rendering')
    register_event('recipes.rendered')
  end

  def self.events
    @events ||= Events.new
  end
end

Tapy.events.subscribe(Tapy::Listeners::LogHandler.new)

require 'tapy/cli'
