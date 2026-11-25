# frozen_string_literal: true

require "json"
require_relative "controllers/api/v1/isbn13_completions_controller"
require_relative "serializers/isbn13_completion_serializer"

class ApiApp
  JSON_HEADERS = { "content-type" => "application/json; charset=utf-8" }.freeze

  def self.call(env)
    new.call(env)
  end

  def call(env)
    method = env["REQUEST_METHOD"].to_s.upcase
    path = env["PATH_INFO"].to_s

    case [method, path]
    when ["GET", "/health"]
      [200, JSON_HEADERS.dup, [JSON.generate({ status: "ok" })]]
    when ["POST", "/api/v1/isbn13/complete"]
      raw_body = read_body(env["rack.input"])
      Api::V1::Isbn13CompletionsController.new.create(
        raw_body: raw_body,
        content_type: env["CONTENT_TYPE"]
      )
    else
      handle_unmatched(method, path)
    end
  rescue StandardError
    body = Serializers::Isbn13CompletionSerializer.render_errors(
      [{ code: "internal_error", message: "An unexpected error occurred" }]
    )
    [500, JSON_HEADERS.dup, [body]]
  end

  private

  def read_body(io)
    return "" if io.nil?

    io.rewind if io.respond_to?(:rewind)
    io.read.to_s
  end

  def handle_unmatched(_method, path)
    if path == "/api/v1/isbn13/complete"
      body = Serializers::Isbn13CompletionSerializer.render_errors(
        [{ code: "method_not_allowed", message: "Use POST for /api/v1/isbn13/complete" }]
      )
      return [405, JSON_HEADERS.merge("allow" => "POST"), [body]]
    end

    body = Serializers::Isbn13CompletionSerializer.render_errors(
      [{ code: "not_found", message: "Route not found" }]
    )
    [404, JSON_HEADERS.dup, [body]]
  end
end
