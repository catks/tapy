# frozen_string_literal: true

module Tapy
  module Listeners
    class LogHandler
      def initialize(stderr: $stderr)
        @stderr = stderr
      end

      def on_recipes_starting(event)
        @stderr.puts "======== #{event[:recipe].git_reference} ========"
      end

      def on_recipes_missing(event)
        @stderr.puts "\n\t#{event[:recipe].git_reference} is missing"
      end

      def on_recipes_installing(event)
        @stderr.puts "\n\tInstalling #{event[:recipe].git_reference}"
      end

      def on_recipes_installed(event)
        @stderr.puts "\tInstalled on #{event[:recipe].path}"
      end

      def on_recipes_uninstalling(event)
        @stderr.puts "\n\tUninstalling #{event[:recipe].git_reference}"
      end

      def on_recipes_uninstalled(event)
        @stderr.puts "\tRecipe #{event[:recipe].git_reference} removed from#{event[:recipe].path}"
      end

      def on_recipes_updating(event)
        @stderr.puts "\tUpdating recipe in #{event[:recipe].path}"
      end

      def on_recipes_updated(event)
        @stderr.puts "\tRecipe #{event[:recipe].git_reference} updated"
      end

      def on_recipes_rendering(event)
        @stderr.puts "\n\tRendering #{recipe_filepath(event[:recipe], event[:file])}"
      end

      def on_recipes_rendered(event)
        @stderr.puts "\tRendered in #{event[:install_path]}"
      end

      def on_tapy_error(event)
        error = event[:error]
        error_name = error.class.name.split('::').last
        error_message = error.message.split("\n").map { |line| "\t #{line}".chomp(' ') }.join("\n")
        @stderr.puts "\n\t[#{error_name}]\n\n#{error_message}"
      end

      private

      def recipe_filepath(recipe, file)
        file.to_s.split(recipe.path.basename.to_s).last[1..-1]
      end
    end
  end
end
