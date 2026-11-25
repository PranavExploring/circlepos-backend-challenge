# frozen_string_literal: true

require "json"
require "stringio"
require "minitest/autorun"
require_relative "../app/api_app"

class Isbn13EndpointTest < Minitest::Test
  def post_json(path, body, content_type: "application/json")
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => path,
      "CONTENT_TYPE" => content_type,
      "rack.input" => StringIO.new(body.to_s)
    }
    status, headers, response_body = ApiApp.call(env)
    [status, headers, JSON.parse(response_body.join)]
  end

  def test_health_check
    status, headers, body = ApiApp.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/health")
    assert_equal 200, status
    assert_equal "application/json; charset=utf-8", headers["content-type"]
    assert_equal({ "status" => "ok" }, JSON.parse(body.join))
  end

  def test_completes_valid_isbn12_string
    status, headers, json = post_json("/api/v1/isbn13/complete", JSON.generate({ isbn12: "978014300723" }))

    assert_equal 200, status
    assert_equal "application/json; charset=utf-8", headers["content-type"]
    assert_equal "isbn13_completion", json.dig("data", "type")
    assert_equal "978014300723", json.dig("data", "attributes", "input")
    assert_equal 4, json.dig("data", "attributes", "check_digit")
    assert_equal "9780143007234", json.dig("data", "attributes", "isbn13")
  end

  def test_completes_valid_isbn12_integer_and_ignores_extra_fields
    payload = JSON.generate({ isbn12: 978014300763, unexpected: "ignored" })
    status, _headers, json = post_json("/api/v1/isbn13/complete", payload)

    assert_equal 200, status
    assert_equal 0, json.dig("data", "attributes", "check_digit")
    assert_equal "9780143007630", json.dig("data", "attributes", "isbn13")
  end

  def test_rejects_unsupported_content_type
    status, _headers, json = post_json("/api/v1/isbn13/complete", '{"isbn12":"978014300723"}', content_type: "text/plain")

    assert_equal 415, status
    assert_equal "unsupported_media_type", json.dig("errors", 0, "code")
  end

  def test_rejects_malformed_json
    status, _headers, json = post_json("/api/v1/isbn13/complete", "{bad json")

    assert_equal 400, status
    assert_equal "invalid_json", json.dig("errors", 0, "code")
  end

  def test_rejects_missing_isbn12_field
    status, _headers, json = post_json("/api/v1/isbn13/complete", "{}")

    assert_equal 422, status
    assert_equal "missing_field", json.dig("errors", 0, "code")
    assert_equal "isbn12", json.dig("errors", 0, "field")
  end

  def test_rejects_invalid_isbn12_value_via_domain_layer
    status, _headers, json = post_json("/api/v1/isbn13/complete", JSON.generate({ isbn12: "978-014300723" }))

    assert_equal 422, status
    assert_equal "invalid_isbn12", json.dig("errors", 0, "code")
    assert_equal "isbn12", json.dig("errors", 0, "field")
  end

  def test_returns_405_for_wrong_http_method_and_404_for_unknown_route
    status405, headers405, body405 = ApiApp.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/api/v1/isbn13/complete")
    assert_equal 405, status405
    assert_equal "POST", headers405["allow"]
    assert_equal "method_not_allowed", JSON.parse(body405.join).dig("errors", 0, "code")

    status404, _headers404, body404 = ApiApp.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/unknown")
    assert_equal 404, status404
    assert_equal "not_found", JSON.parse(body404.join).dig("errors", 0, "code")
  end
end
