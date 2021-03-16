require 'pathname'
require 'forwardable'

module Tapy
  class RecipeStore
    extend Forwardable

    attr_accessor :recipes_path

    def_delegators :@store, :all, :find, :delete

    def initialize(recipes_path = '~/.tapy/recipes', prefix: 'tapy-')
      @recipes_path = Pathname.new(recipes_path).expand_path
      @store = Vorx::Store.new(@recipes_path.to_s, store_file: 'recipe_store.yml', repository_prefix: prefix)
    end

    def install(git_reference)
      @store.fetch(git_reference)

      # TODO: Add better error handling in vorx and here
    rescue StandardError => e
      @store.delete(git_reference)

      raise InstallError, e.message
    end

    def uninstall(git_reference)
      @store.delete(git_reference)
    end

    def update(git_reference)
      @store.fetch(recipe)
    rescue StandardError => e
      raise UpdateError, e.message
    end
  end
end
