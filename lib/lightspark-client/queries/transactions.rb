# frozen_string_literal: true

module LightsparkClient
  module Queries
    module Transations
      def get_transaciton(id: nil)
        query = <<~GQL
          query GetTransaction($id: ID!) {
            entity(id: $id) {
              ... on Transaction {
                ...TransactionFragment
              }
            }
          }

          fragment TransactionFragment on Transaction {
            ... on IncomingPayment {
              __typename
              incoming_payment_id: id
              incoming_payment_created_at: created_at
              incoming_payment_updated_at: updated_at
              incoming_payment_status: status
              incoming_payment_resolved_at: resolved_at
              incoming_payment_amount: amount {
                __typename
                currency_amount_original_value: original_value
                currency_amount_original_unit: original_unit
                currency_amount_preferred_currency_unit: preferred_currency_unit
                currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
              }
              incoming_payment_transaction_hash: transaction_hash
              incoming_payment_is_uma: is_uma
              incoming_payment_destination: destination {
                id
              }
              incoming_payment_payment_request: payment_request {
                id
              }
              incoming_payment_uma_post_transaction_data: uma_post_transaction_data {
                __typename
                post_transaction_data_utxo: utxo
                post_transaction_data_amount: amount {
                  __typename
                  currency_amount_original_value: original_value
                  currency_amount_original_unit: original_unit
                  currency_amount_preferred_currency_unit: preferred_currency_unit
                  currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                  currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
                }
              }
              incoming_payment_is_internal_payment: is_internal_payment
            }
          }
        GQL

        variables = { id: id }.compact

        request({ query: query, variables: variables })
      end
    end
  end
end
