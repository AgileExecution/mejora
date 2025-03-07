defmodule MejoraWeb.PaymentNoticeLive do
  use Backpex.LiveResource,
    adapter_config: [
      schema: Mejora.Transactions.PaymentNotice,
      repo: Mejora.Repo,
      update_changeset: &Mejora.Transactions.PaymentNotice.update_changeset/3,
      create_changeset: &Mejora.Transactions.PaymentNotice.create_changeset/3
    ],
    layout: {MejoraWeb.Layouts, :admin},
    pubsub: [
      name: Mejora.PubSub,
      topic: "payment_notices",
      event_prefix: "payment_notice_"
    ]

  alias Mejora.Transactions.PaymentNotice

  @impl Backpex.LiveResource
  def singular_name, do: "Payment Notice"

  @impl Backpex.LiveResource
  def plural_name, do: "Payment Notices"

  @impl Backpex.LiveResource
  def fields, do: PaymentNotice.fields_for_admin_backend()
end
