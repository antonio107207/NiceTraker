import { Controller } from "@hotwired/stimulus"

// Multi-line editable area (for card descriptions)
export default class extends Controller {
  static targets = ["display", "editor", "input"]
  static values  = { url: String, field: String }

  show() {
    this.displayTarget.classList.add("hidden")
    this.editorTarget.classList.remove("hidden")
    this.inputTarget.focus()
  }

  cancel() {
    this.editorTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }

  save() {
    const value = this.inputTarget.value
    const [model, field] = this.fieldValue.replace("]", "").split("[")
    fetch(this.urlValue, {
      method:  "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content },
      body:    JSON.stringify({ [model]: { [field]: value } })
    }).then(() => {
      this.displayTarget.textContent = value || "Add a description…"
      this.cancel()
    })
  }

  connect() {
    this.displayTarget.addEventListener("click", this.show.bind(this))
  }
}
