# frozen_string_literal: true

require 'liquid'
require 'pathname'

module Tapy
  class Recipe
    include Tapy::Utils::PublishHelper
    extend Tapy::Utils::PublishHelper

    FILES_TO_IGNORE = %w[.gitignore .git .git/**/* README.md LICENSE].freeze
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
      files_to_render.each do |filepath|
        file = Pathname.new(filepath)

        next if file.directory?

        # TODO: Change event to recipes.file.rendering

        file_rendered_content = render_file_content(file, args)

        publish('recipes.rendering', recipe: self, file: file)

        install_path = relative_path_from_repo(file, base_path: to)
        write_file(file_rendered_content, install_path: install_path)

        publish('recipes.rendered', recipe: self, file: file, install_path: install_path)
      end
    end

    def path
      @path ||= @store.recipes_path.join(git_repo.folder_name)
    end

    private

    def git_repo
      @git_repo ||= @store.find(@git_reference)
    end

    def files_to_render
      @files_to_render ||= begin
        all_files = Dir.glob(path.join('**/*'), File::FNM_DOTMATCH)

        files_to_ignore = Dir.glob(FILES_TO_IGNORE.map { |f| path.join(f) }, File::FNM_DOTMATCH)

        folders_references = ->(filepath) { filepath.match?(%r{/\.$}) }

        (all_files - files_to_ignore).reject(&folders_references)
      end
    end

    def render_file_content(file, args)
      file_raw_content = file.read
      template = Liquid::Template.parse(file_raw_content)
      template.render(args)
    end

    def write_file(file_content, install_path:)
      install_path.dirname.mkpath
      install_path.write(file_content)
    end

    def relative_path_from_repo(file, base_path: '.')
      Pathname.new(base_path).join(file.to_s.split("#{git_repo.folder_name}/").last).expand_path
    end
  end
end
