RSpec.describe Tapy::ArgOptions do
  describe '.parse' do
    [
      ['foo:bar baz', { 'foo' => 'bar', 'baz' => true }],
      ['foo:bar foo2:test baz:foo', { 'foo' => 'bar', 'foo2' => 'test', 'baz' => 'foo' }],
      ['foo:bar foo2:test bar baz:foo', { 'foo' => 'bar', 'foo2' => 'test', 'bar' => true, 'baz' => 'foo' }],
      ['my_option:some-value my-other-option:other_value', { 'my_option' => 'some-value', 'my-other-option' => 'other_value' }],
      ['foo_version:1.0.3-rc.1 bar_version:90.0.9 baz', { 'foo_version' => '1.0.3-rc.1', 'bar_version' => '90.0.9', 'baz' => true }]
    ].each do |input, expected_output|
      it "#{input} to return #{expected_output}" do
        expect(described_class.parse(*input)).to eq(expected_output)
      end
    end
  end
end
