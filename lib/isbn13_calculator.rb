# frozen_string_literal: true

class Isbn13Calculator
  class InvalidInputError < ArgumentError; end

  REQUIRED_LENGTH = 12
  VALID_FORMAT = /\A[0-9]{12}\z/

  def self.complete(isbn12)
    new(isbn12).complete
  end

  def self.check_digit(isbn12)
    new(isbn12).check_digit
  end

  def initialize(isbn12)
    @isbn12 = normalize_and_validate(isbn12)
  end

  def complete
    "#{@isbn12}#{check_digit}"
  end

  def check_digit
    weighted_sum = @isbn12.each_char.with_index.sum do |char, index|
      weight = index.even? ? 1 : 3
      char.to_i * weight
    end

    remainder = weighted_sum % 10
    digit = 10 - remainder
    digit == 10 ? 0 : digit
  end

  private

  def normalize_and_validate(input)
    unless input.is_a?(String) || (input.is_a?(Integer) && input >= 0)
      raise InvalidInputError,
            "Expected a 12-digit String or non-negative Integer, got #{input.class}"
    end

    normalized = input.to_s

    unless VALID_FORMAT.match?(normalized)
      raise InvalidInputError,
            "ISBN-13 prefix must be exactly #{REQUIRED_LENGTH} ASCII digits (got #{normalized.inspect})"
    end

    normalized
  end
end
