RSpec.describe Tapy::Recipe do
  let(:instance) { described_class.new(git_reference, store: store) }
  let(:store) { Tapy::RecipeStore.new('tmp/recipes') }

  let(:git_reference) { 'http://gitserver/tapy-no-eczist.git' }

  describe '.install' do
    subject(:install) { instance.install }

    before { reload_tmp }

    context 'when repository exists but is not fetched' do
      let(:git_reference) { 'http://gitserver/tapy-docker.git' }

      it 'install the repository' do
        install

        # TODO verify if installtion ocurred
      end
    end

    context 'when repository doesnt exist' do
      it 'raises a error' do
        expect { install }.to raise_error(Tapy::InstallError)
      end
    end
  end

  # TODO: Add more tests
end
