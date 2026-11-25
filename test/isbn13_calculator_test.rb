# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/isbn13_calculator"

class Isbn13CalculatorTest < Minitest::Test
  def test_specification_example_as_string
    assert_equal 4, Isbn13Calculator.check_digit("978014300723")
    assert_equal "9780143007234", Isbn13Calculator.complete("978014300723")
  end

  def test_specification_example_as_integer
    assert_equal "9780143007234", Isbn13Calculator.complete(978014300723)
  end

  def test_check_digit_ten_wraps_to_zero
    assert_equal 0, Isbn13Calculator.check_digit("978014300763")
    assert_equal "9780143007630", Isbn13Calculator.complete("978014300763")
  end

  def test_additional_known_isbns
    assert_equal "9780306406157", Isbn13Calculator.complete("978030640615")
    assert_equal "9780132350884", Isbn13Calculator.complete("978013235088")
    assert_equal "9780134685991", Isbn13Calculator.complete("978013468599")
  end

  def test_preserves_leading_zeros_for_string_input
    assert_equal "0000000000000", Isbn13Calculator.complete("000000000000")
  end

  def test_rejects_wrong_lengths
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete("") }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete("97801430072") }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete("9780143007234") }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete(12345) }
  end

  def test_rejects_non_digit_characters_and_whitespace
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete("978-014300723") }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete("97801430072a") }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete(" 978014300723") }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete("978014300723\n") }
  end

  def test_rejects_invalid_types_and_negative_numbers
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete(nil) }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete(-978014300723) }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete(978014300723.0) }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete(true) }
    assert_raises(Isbn13Calculator::InvalidInputError) { Isbn13Calculator.complete([978014300723]) }
  end
end
