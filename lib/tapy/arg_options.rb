module Tapy
  module ArgOptions
    OPTION_REGEXP = /([[[:alnum:]]_-]+):([[[:alnum:]]_.-]+)/.freeze

    def self.parse(arg_string)
      args = arg_string.split

      args.map do |arg|
        key, value = OPTION_REGEXP.match(arg)&.captures

        # TODO: Use blank?
        if !key && !value
          key = arg
          value = true
        end

        [key, value]
      end.to_h
    end
  end
end
