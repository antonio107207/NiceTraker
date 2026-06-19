// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from "@hotwired/turbo-rails"
import "turbo_stream_actions"
import "controllers"
import "board_drag"

import "trix"
import "@rails/actiontext"

Turbo.config.forms.confirm = (message) => {
  const dialog = document.getElementById("confirm_dialog")
  if (!dialog) return Promise.resolve(window.confirm(message))

  document.getElementById("confirm_dialog_message").textContent = message

  return new Promise((resolve) => {
    const ok     = document.getElementById("confirm_dialog_ok")
    const cancel = document.getElementById("confirm_dialog_cancel")

    const finish = (result) => {
      dialog.close()
      ok.removeEventListener("click", onOk)
      cancel.removeEventListener("click", onCancel)
      resolve(result)
    }
    const onOk     = () => finish(true)
    const onCancel = () => finish(false)

    ok.addEventListener("click", onOk,     { once: true })
    cancel.addEventListener("click", onCancel, { once: true })
    dialog.addEventListener("cancel", () => finish(false), { once: true })

    dialog.showModal()
  })
}
