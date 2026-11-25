# frozen_string_literal: true

require "json"

module Serializers
  class Isbn13CompletionSerializer
    def self.render_success(data)
      JSON.generate(
        {
          data: {
            type: "isbn13_completion",
            attributes: {
              input: data.fetch(:input),
              check_digit: data.fetch(:check_digit),
              isbn13: data.fetch(:isbn13)
            }
          }
        }
      )
    end

    def self.render_errors(errors)
      JSON.generate(
        {
          errors: errors.map do |err|
            payload = { code: err.fetch(:code), message: err.fetch(:message) }
            payload[:field] = err[:field] if err[:field]
            payload
          end
        }
      )
    end
  end
end
