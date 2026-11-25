# frozen_string_literal: true

require "json"

module Contracts
  class Isbn13CompletionContract
    Result = Data.define(:valid, :params, :errors, :status) do
      def valid?
        valid
      end
    end

    def self.call(raw_body, content_type:)
      new(raw_body, content_type: content_type).call
    end

    def initialize(raw_body, content_type:)
      @raw_body = raw_body
      @content_type = content_type.to_s
    end

    def call
      unless json_content_type?
        return failure(415, "unsupported_media_type", "Content-Type must be application/json")
      end

      payload = parse_json(@raw_body)
      return payload if payload.is_a?(Result)

      unless payload.is_a?(Hash)
        return failure(400, "invalid_payload", "Request body must be a JSON object")
      end

      validate_fields(payload)
    end

    private

    def json_content_type?
      @content_type.downcase.start_with?("application/json")
    end

    def parse_json(raw)
      return failure(400, "empty_body", "Request body cannot be empty") if raw.nil? || raw.strip.empty?

      JSON.parse(raw)
    rescue JSON::ParserError
      failure(400, "invalid_json", "Request body contains malformed JSON")
    end

    def validate_fields(payload)
      unless payload.key?("isbn12")
        return failure(422, "missing_field", "isbn12 is required", field: "isbn12")
      end

      isbn12 = payload["isbn12"]
      unless isbn12.is_a?(String) || (isbn12.is_a?(Integer) && isbn12 >= 0)
        return failure(
          422,
          "invalid_type",
          "isbn12 must be a 12-digit string or non-negative integer",
          field: "isbn12"
        )
      end

      Result.new(valid: true, params: { isbn12: isbn12 }, errors: [], status: 200)
    end

    def failure(status, code, message, field: nil)
      error = { code: code, message: message }
      error[:field] = field if field
      Result.new(valid: false, params: {}, errors: [error], status: status)
    end
  end
end
