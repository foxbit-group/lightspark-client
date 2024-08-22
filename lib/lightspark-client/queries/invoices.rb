# frozen_string_literal: true

module LightsparkClient
  module Queries
    module Invoices
      def get_invoice(id: nil)
        query = <<~GQL
          query GetPaymentRequest($id: ID!) {
            entity(id: $id) {
              ... on PaymentRequest {
                ...PaymentRequestFragment
              }
            }
          }

          fragment PaymentRequestFragment on PaymentRequest {
            __typename
            ... on Invoice {
              __typename
              invoice_id: id
              invoice_created_at: created_at
              invoice_updated_at: updated_at
              invoice_data: data {
                __typename
                invoice_data_encoded_payment_request: encoded_payment_request
                invoice_data_bitcoin_network: bitcoin_network
                invoice_data_payment_hash: payment_hash
                invoice_data_amount: amount {
                  __typename
                  currency_amount_original_value: original_value
                  currency_amount_original_unit: original_unit
                  currency_amount_preferred_currency_unit: preferred_currency_unit
                  currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                  currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
                }
                invoice_data_created_at: created_at
                invoice_data_expires_at: expires_at
                invoice_data_memo: memo
              }
              invoice_status: status
              invoice_amount_paid: amount_paid {
                __typename
                currency_amount_original_value: original_value
                currency_amount_original_unit: original_unit
                currency_amount_preferred_currency_unit: preferred_currency_unit
                currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
              }
              invoice_is_uma: is_uma
              invoice_is_lnurl: is_lnurl
            }
          }
        GQL

        variables = { id: id }.compact

        request({ query: query, variables: variables })
      end

      # this method is deprecated, used only for compatibility
      def get_transfer(wallet_id, id: nil)
        get_invoice(id: id)
      end
    end
  end
end
