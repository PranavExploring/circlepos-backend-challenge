# CirclePOS Backend Developer Challenge

Ruby 3.3 solution implementing:
- **Part 1:** ISBN-13 check-digit calculator (`Isbn13Calculator`) with strict input validation and Minitest coverage.
- **Part 3:** Zero-dependency, Rack-compatible Rails-style JSON API endpoint (`POST /api/v1/isbn13/complete` and `GET /health`) with explicit request validation, service, domain, and serialization boundaries.

## Project Structure

```text
.
├── .github/workflows/ci.yml                              # GitHub Actions CI (Ruby 3.3)
├── lib/
│   └── isbn13_calculator.rb                              # Pure domain object (Part 1)
├── app/
│   ├── api_app.rb                                        # Rack router & top-level error handling
│   ├── contracts/
│   │   └── isbn13_completion_contract.rb                 # Content-Type, JSON, and field validation
│   ├── controllers/api/v1/
│   │   └── isbn13_completions_controller.rb              # Thin HTTP coordinator
│   ├── services/
│   │   └── complete_isbn13_service.rb                    # Business boundary returning immutable Result
│   └── serializers/
│       └── isbn13_completion_serializer.rb               # Consistent JSON success & error envelopes
└── test/
    ├── isbn13_calculator_test.rb                         # Unit tests for ISBN-13 calculation & edge cases
    └── isbn13_endpoint_test.rb                           # End-to-end Rack tests for the HTTP endpoint
```

## Requirements

- Ruby 3.3+ (uses standard library only; no external gems required)

## Running Tests

Run both Minitest suites:

```bash
ruby test/isbn13_calculator_test.rb
ruby test/isbn13_endpoint_test.rb
```

Verified in GitHub Actions CI on Ruby 3.3:
- `test/isbn13_calculator_test.rb` — 8 runs, 22 assertions, 0 failures, 0 errors
- `test/isbn13_endpoint_test.rb` — 8 runs, 27 assertions, 0 failures, 0 errors

## Usage Examples

### Part 1: ISBN-13 Calculator

```bash
ruby -Ilib -r isbn13_calculator -e 'puts Isbn13Calculator.complete("978014300723")'
# => 9780143007234
```

### Part 3: Rack-Compatible JSON Endpoint

Invoke `POST /api/v1/isbn13/complete` directly through `ApiApp`:

```bash
ruby -r stringio -r ./app/api_app -e '
  status, _headers, body = ApiApp.call(
    "REQUEST_METHOD" => "POST",
    "PATH_INFO" => "/api/v1/isbn13/complete",
    "CONTENT_TYPE" => "application/json",
    "rack.input" => StringIO.new(%({"isbn12":"978014300723"}))
  )
  puts "HTTP #{status}: #{body.join}"
'
```

Sample `200 OK` response:

```json
{
  "data": {
    "type": "isbn13_completion",
    "attributes": {
      "input": "978014300723",
      "check_digit": 4,
      "isbn13": "9780143007234"
    }
  }
}
```

### HTTP Status Codes

| Status | Condition |
| --- | --- |
| `200` | Valid 12-digit ISBN completed (`POST /api/v1/isbn13/complete`) or healthy (`GET /health`) |
| `400` | Empty body, malformed JSON, or non-object JSON payload |
| `404` | Unknown route |
| `405` | Unsupported HTTP method on `/api/v1/isbn13/complete` (includes `Allow: POST`) |
| `415` | Missing or non-`application/json` `Content-Type` header |
| `422` | Missing `isbn12`, invalid type, wrong length, or non-digit characters |
| `500` | Unexpected internal error (returns structured JSON without leaking stack traces) |
