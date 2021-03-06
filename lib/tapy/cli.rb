module Tapy
  module CLI
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      desc 'Prints Tapy Version'

      def call(*)
        puts Tapy::VERSION
      end
    end

    class Install < Dry::CLI::Command
      desc 'Install a Tapy recipe'

      argument :recipe_reference, type: :string, required: true, desc: 'Recipe, eg: `catks/docker`, `github:catks/docker` or `git@github.com:catks/tapy-docker.git`'

      def call(recipe_reference:)
        recipe = Tapy::Recipe.new(recipe_reference)

        recipe.install
      end
    end

    class Generate < Dry::CLI::Command
      desc 'Generate files folowwing a Tapy recipe'

      argument :recipe_reference, type: :string, required: true, desc: 'Recipe, eg: `catks/docker`, `github:catks/docker` or `git@github.com:catks/tapy-docker.git`'
      argument :recipe_options, type: :array, required: false, desc: "Optional recipe options"
      option :to, type: :string, default: '.', desc: "Output folder"

      def call(recipe_reference:, recipe_options: [], **options)
        recipe = Tapy::Recipe.new(recipe_reference)

        recipe.install unless recipe.exist?

        recipe_args = Tapy::ArgOptions.parse(recipe_options.join(' '))

        recipe.render(args: recipe_args, to: options[:to])
      end
    end

    register '--version', Version, aliases: ['-v']
    register 'generate', Generate, aliases: ['g']
    register 'install', Generate
  end
end
