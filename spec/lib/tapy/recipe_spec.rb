RSpec.describe Tapy::Recipe do
  let(:instance) { described_class.new(git_reference, recipes_path: 'tmp/recipes') }

  let(:git_reference) { 'http://gitserver/tapy-no-eczist.git' }

  describe '.install' do
    subject(:install) { instance.install }

    before { reload_tmp }

    context 'when repository doesnt exist' do
      it 'raises a error' do
        expect { install }.to raise_error(described_class::InstallError)
      end
    end
  end

  # TODO: Add more tests
end
