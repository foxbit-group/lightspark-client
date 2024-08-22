# frozen_string_literal: true

module LightsparkClient
  module Mutations
    module Invoices
      def create_invoice(node_id:, amount_msats:, memo: nil, type: nil, expiry_secs: nil)
        mutation = <<~GQL
          mutation CreateInvoice(
            $node_id: ID!
            $amount_msats: Long!
            $memo: String
            $type: InvoiceType = null
            $expiry_secs: Int = null
          ) {
            create_invoice(
              input: {
                node_id: $node_id,
                amount_msats: $amount_msats,
                memo: $memo,
                invoice_type: $type,
                expiry_secs: $expiry_secs
              }
            ) {
              invoice {
                id
                data {
                  encoded_payment_request
                  payment_hash
                }
              }
            }
          }
        GQL

        variables = {
          node_id: node_id,
          amount_msats: amount_msats,
          memo: memo,
          type: type,
          expiry_secs: expiry_secs
        }.compact

        request({ query: mutation, variables: variables })
      end
    end
  end
end
