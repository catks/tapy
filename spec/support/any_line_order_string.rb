# frozen_string_literal: true

class AnyLineOrderString
  include Comparable

  def initialize(original_string)
    @original_string = original_string
  end

  def <=>(other)
    string_as_array <=> AnyLineOrderString.new(other).string_as_array
  end

  def string_as_array
    @string_as_array ||= @original_string.split("\n")
                                         .reject(&:empty?)
                                         .sort
  end
end
