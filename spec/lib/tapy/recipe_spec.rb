RSpec.describe Tapy::Recipe do
  let(:instance) { described_class.new(git_reference) }

  let(:git_reference) { 'catks/docker-ruby' }

  describe '.install' do
    subject(:install) { instance.install }

    context 'when repository doesnt exist' do
      it 'raises a error' do
        expect { install }.to raise_error(described_class::InstallError)
      end
    end
  end
end
