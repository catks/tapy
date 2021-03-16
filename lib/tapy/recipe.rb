require 'liquid'
require 'pathname'

module Tapy
  class Recipe
    include Tapy::Utils::PublishHelper
    extend Tapy::Utils::PublishHelper

    FILES_TO_IGNORE = %w[.gitignore .git README.md LICENSE].freeze
    DEFAULT_STORE = Tapy::RecipeStore.new('~/.tapy/recipes')

    attr_reader :git_reference

    def initialize(git_reference, store: DEFAULT_STORE)
      @git_reference = git_reference
      @store = store

      publish('recipes.starting', recipe: self)
    end

    def install
      publish('recipes.installing', recipe: self)

      @store.install(@git_reference)

      publish('recipes.installed', recipe: self)
    end

    def uninstall
      publish('recipes.uninstalling', recipe: self)

      raise Tapy::UninstallError, "Recipe #{@git_reference} is not installed" unless installed?

      @store.uninstall(@git_reference)

      publish('recipes.uninstalled', recipe: self)
    end

    def update
      publish('recipes.updating', recipe: self)

      @store.update(@git_reference)

      publish('recipes.updated', recipe: self)
    end

    def installed?
      !!git_repo
    end

    def render(args: {}, to: '.')
      files_to_render = Dir[path.join('**/*')].reject { |file| FILES_TO_IGNORE.include?(file.split('/').last) }

      files_to_render.each do |filepath|
        file = Pathname.new(filepath)

        next if file.directory?

        # TODO: Change event to recipes.file.rendering

        file_raw_content = file.read

        template = Liquid::Template.parse(file_raw_content)
        file_rendered_content = template.render(args)

        relative_path = Pathname.new(to).join(file.to_s.split("#{git_repo.folder_name}/").last).expand_path

        publish('recipes.rendering', recipe: self, file: file)

        relative_path.dirname.mkpath
        relative_path.write(file_rendered_content)

        publish('recipes.rendered', recipe: self, file: file, install_path: relative_path)
      end
    end

    def path
      @path ||= @store.recipes_path.join(git_repo.folder_name)
    end

    private

    def git_repo
      @git_repo ||= @store.find(@git_reference)
    end
  end
end
