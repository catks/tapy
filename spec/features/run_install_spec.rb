# frozen_string_literal: true

RSpec.describe 'tapy install', type: :feature do
  subject(:tapy_install) { run_command("tapy install #{git_reference}") }

  let(:git_reference) { 'http://gitserver/tapy-docker.git' }

  # TODO: Use tmp folder
  let(:store) { Tapy::RecipeStore.new }
  let(:recipe) { Tapy::Recipe.new(git_reference) }

  before do
    reload_tmp

    store.delete(git_reference)
  end

  context 'with a valid repo' do
    it 'creates the folder' do
      expect { tapy_install }.to change { recipe.installed? }.from(false).to(true)
    end

    it 'log steps' do
      tapy_install

      expected_stderr_output = <<~DESC
        ======== http://gitserver/tapy-docker.git ========

        \tInstalling http://gitserver/tapy-docker.git
        \tInstalled on /root/.tapy/recipes/tapy-docker@master
      DESC

      expect(command_stderr).to eq(expected_stderr_output)
    end
  end
end
