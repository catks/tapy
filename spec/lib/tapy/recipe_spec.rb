# frozen_string_literal: true

RSpec.describe Tapy::Recipe do
  let(:instance) { described_class.new(git_reference, store: store) }
  let(:store) { Tapy::RecipeStore.new('tmp/recipes') }

  let(:git_reference) { 'http://gitserver/tapy-no-eczist.git' }

  describe '#install' do
    subject(:install) { instance.install }

    before { reload_tmp }

    context 'when repository exists but is not fetched' do
      let(:git_reference) { 'http://gitserver/tapy-docker.git' }

      it 'install the repository' do
        install

        # TODO: Verify if installation occurred
      end
    end

    context 'when repository doesnt exist' do
      it 'raises a error' do
        expect { install }.to raise_error(Tapy::InstallError)
      end
    end
  end

  describe '#render' do
    subject(:render) { instance.render(to: 'tmp/') }

    let(:git_reference) { 'http://gitserver/tapy-docker.git' }

    context 'when installed' do
      before do
        instance.install
      end

      it 'renders files' do
        render
      end
    end
  end

  # TODO: Add more tests
end
