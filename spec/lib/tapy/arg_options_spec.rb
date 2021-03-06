RSpec.describe Tapy::ArgOptions do
  describe '.parse' do
    [
      ['foo:bar baz', { 'foo' => 'bar', 'baz' => true }],
      ['foo:bar foo2:test baz:foo', { 'foo' => 'bar', 'foo2' => 'test', 'baz' => 'foo' }],
      ['foo:bar foo2:test bar baz:foo', { 'foo' => 'bar', 'foo2' => 'test', 'bar' => true, 'baz' => 'foo' }],
      ['my_option:some-value my-other-option:other_value', { 'my_option' => 'some-value', 'my-other-option' => 'other_value'}]
    ].each do |input, expected_output|
      it "#{input} to return #{expected_output}" do
        expect(described_class.parse(*input)).to eq(expected_output)
      end
    end
  end
end
