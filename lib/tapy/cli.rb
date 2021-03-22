# frozen_string_literal: true

module Tapy
  module CLI
    extend Dry::CLI::Registry

    class Base < Dry::CLI::Command
      include Tapy::Utils::PublishHelper
    end

    class Version < Base
      desc 'Prints Tapy Version'

      def call(*)
        puts Tapy::VERSION
      end
    end

    class Install < Base
      desc 'Install or Update a Tapy recipe'

      argument :recipe_reference,
               type: :string, required: true,
               desc: 'Recipe, eg: `catks/docker`, `github:catks/docker` or `git@github.com:catks/tapy-docker.git`'

      def call(recipe_reference:)
        # TODO: refactor to a publish method, eg publish('recipe.start', recipe: recipe)
        recipe = Tapy::Recipe.new(recipe_reference)

        recipe.install
      end
    end

    class Uninstall < Base
      desc 'Install or Update a Tapy recipe'

      argument :recipe_reference,
               type: :string, required: true,
               desc: 'Recipe, eg: `catks/docker`, `github:catks/docker` or `git@github.com:catks/tapy-docker.git`'

      def call(recipe_reference:)
        recipe = Tapy::Recipe.new(recipe_reference)

        recipe.uninstall
      end
    end

    class Generate < Base
      desc 'Generate files folowwing a Tapy recipe'

      argument :recipe_reference,
               type: :string, required: true,
               desc: 'Recipe, eg: `catks/docker`, `github:catks/docker` or `git@github.com:catks/tapy-docker.git`'

      argument :recipe_options, type: :array, required: false, desc: 'Optional recipe options'
      option :to, type: :string, default: '.', desc: 'Output folder'

      def call(recipe_reference:, recipe_options: [], **options)
        recipe = Tapy::Recipe.new(recipe_reference)

        unless recipe.installed?
          publish('recipes.missing', recipe: recipe)
          recipe.install
        end

        recipe_args = Tapy::ArgOptions.parse(recipe_options.join(' '))

        recipe.render(args: recipe_args, to: options[:to])
      end
    end

    register '--version', Version, aliases: ['-v']
    register 'generate', Generate, aliases: ['g']
    register 'install', Install
    register 'uninstall', Uninstall
  end
end
