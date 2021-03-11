require 'liquid'
require 'pathname'

module Tapy
  class Recipe
    FILES_TO_IGNORE = %w[.gitignore .git README.md LICENSE].freeze
    InstallError = Class.new(StandardError)

    attr_reader :git_reference

    def initialize(git_reference, recipes_path: '~/.tapy/recipes', events: Tapy.events)
      @recipes_path = Pathname.new(recipes_path).expand_path
      @git_reference = git_reference
      @store = Vorx::Store.new(@recipes_path.to_s, store_file: 'recipe_store.yml', repository_prefix: 'tapy-')
      @events = events
    end

    def install
      @store.fetch(@git_reference)

      # TODO: Add better error handling in vorx and here
    rescue StandardError => e
      @store.delete(@git_reference)

      raise InstallError, e.message
    end

    def exist?
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

        publish('recipes.rendering', file: file)

        relative_path.dirname.mkpath
        relative_path.write(file_rendered_content)

        publish('recipes.rendered', file: file, install_path: relative_path)
      end
    end

    # TODO: Maybe rename to install_path
    def path
      @path ||= @recipes_path.join(git_repo.folder_name)
    end

    private

    def git_repo
      @git_repo ||= @store.find(@git_reference)
    end

    def publish(event, **options)
      @events.publish(event, recipe: self, **options)
    end
  end
end
