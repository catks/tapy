# frozen_string_literal: true

module Helpers
  def disable_warnings
    @old_verbose = $VERBOSE
    $VERBOSE = nil

    yield

    $VERBOSE = @old_verbose
  end

  def clear_tmp
    tmp_folder.rmtree if tmp_folder.exist?
  end

  def create_tmp
    tmp_folder.mkpath
  end

  def reload_tmp
    clear_tmp
    create_tmp
  end

  def run_command(command, path: '.', envs: {})
    envs_string = envs.map { |env, value| "#{env}='#{value}'" }.join(' ')

    command_string = [
      envs_string,
      "cd #{path}",
      command
    ].reject(&:empty?).join(' && ')

    @command_stdout, @command_stderr, @command_status = Open3.capture3(command_string)
  end

  attr_reader :command_stdout, :command_stderr, :command_status

  private

  def tmp_folder
    @tmp_folder ||= Pathname.new('tmp')
  end
end
