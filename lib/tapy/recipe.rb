require 'liquid'
require 'pathname'

module Tapy
  class Recipe
    FILES_TO_IGNORE = %w[.gitignore .git README.md LICENSE].freeze
    InstallError = Class.new(StandardError)

    def initialize(git_reference, recipes_path: '~/.tapy/recipes')
      @recipes_path = Pathname.new(recipes_path).expand_path
      @git_reference = git_reference
      @store = Vorx::Store.new(@recipes_path.to_s, store_file: 'recipe_store.yml', repository_prefix: 'tapy-')
    end

    def install
      @store.fetch(@git_reference)

      # TODO: Add better error handling in vorx and here
    rescue StandardError => e
      raise InstallError, e.message
    end

    def exist?
      !!git_repo
    end

    def render(args: {}, to: '.')
      files_to_render = Dir[recipe_path.join('*')].reject { |file| FILES_TO_IGNORE.include?(file) }

      files_to_render.each do |filepath|
        file = Pathname.new(filepath)
        file_raw_content = file.read
        template = Liquid::Template.parse(file_raw_content)
        file_rendered_content = template.render(args)

        # TODO: Consider relative path and subfolders to create the same structure
        IO.write(file.basename.to_s, file_rendered_content)
      end
    end

    private

    def git_repo
      @git_repo ||= @store.find(@git_reference)
    end

    def recipe_path
      @recipes_path.join(git_repo.folder_name)
    end
  end
end
