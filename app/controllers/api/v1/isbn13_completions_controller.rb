# frozen_string_literal: true

require_relative "../../../contracts/isbn13_completion_contract"
require_relative "../../../services/complete_isbn13_service"
require_relative "../../../serializers/isbn13_completion_serializer"

module Api
  module V1
    class Isbn13CompletionsController
      JSON_HEADERS = { "content-type" => "application/json; charset=utf-8" }.freeze

      def create(raw_body:, content_type:)
        contract = Contracts::Isbn13CompletionContract.call(raw_body, content_type: content_type)
        unless contract.valid?
          return json_response(
            contract.status,
            Serializers::Isbn13CompletionSerializer.render_errors(contract.errors)
          )
        end

        outcome = Services::CompleteIsbn13Service.call(isbn12: contract.params[:isbn12])
        if outcome.success?
          json_response(
            outcome.status,
            Serializers::Isbn13CompletionSerializer.render_success(outcome.data)
          )
        else
          json_response(
            outcome.status,
            Serializers::Isbn13CompletionSerializer.render_errors(outcome.errors)
          )
        end
      end

      private

      def json_response(status, body)
        [status, JSON_HEADERS.dup, [body]]
      end
    end
  end
end
