# frozen_string_literal: true

require_relative "../../lib/isbn13_calculator"

module Services
  class CompleteIsbn13Service
    Result = Data.define(:success, :data, :errors, :status) do
      def success?
        success
      end
    end

    def self.call(isbn12:)
      new(isbn12: isbn12).call
    end

    def initialize(isbn12:)
      @isbn12 = isbn12
    end

    def call
      calculator = Isbn13Calculator.new(@isbn12)

      Result.new(
        success: true,
        data: {
          input: @isbn12.to_s,
          check_digit: calculator.check_digit,
          isbn13: calculator.complete
        },
        errors: [],
        status: 200
      )
    rescue Isbn13Calculator::InvalidInputError => e
      Result.new(
        success: false,
        data: nil,
        errors: [{ field: "isbn12", code: "invalid_isbn12", message: e.message }],
        status: 422
      )
    end
  end
end
