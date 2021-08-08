# frozen_string_literal: true

RSpec.describe 'tapy install', type: :feature do
  subject(:tapy_uninstall) { run_command("tapy uninstall #{git_reference}") }

  let(:git_reference) { 'http://gitserver/tapy-docker.git' }

  # TODO: Use tmp folder
  let(:store) { Tapy::RecipeStore.new }

  def recipe
    Tapy::Recipe.new(git_reference)
  end

  before do
    reload_tmp

    store.delete(git_reference)
  end

  context 'with a valid repo' do
    context 'that is not fetched' do
      it 'exists in error' do
        tapy_uninstall

        expect(command_status.to_i).to be > 0
      end

      it 'log steps' do
        tapy_uninstall

        # TODO: Remove space in before the "Recipe in last line"
        expected_stderr_output = <<~DESC
          ======== http://gitserver/tapy-docker.git ========

          \tUninstalling http://gitserver/tapy-docker.git

          \t[UninstallError]

          \t Recipe http://gitserver/tapy-docker.git is not installed
        DESC

        expect(command_stderr).to eq(expected_stderr_output)
      end
    end

    context 'that is fetched' do
      before do
        run_command("tapy install #{git_reference}")
      end

      it 'exists in success' do
        tapy_uninstall

        expect(command_status.to_i).to eq(0)
      end

      it 'deletes the folder' do
        expect { tapy_uninstall }.to change { recipe.installed? }.from(true).to(false)
      end

      it 'log steps' do
        tapy_uninstall

        expected_stderr_output = <<~DESC
          ======== http://gitserver/tapy-docker.git ========

          \tUninstalling http://gitserver/tapy-docker.git
          \tRecipe http://gitserver/tapy-docker.git removed from/root/.tapy/recipes/tapy-docker@master
        DESC

        expect(command_stderr).to eq(expected_stderr_output)
      end
    end
  end
end
