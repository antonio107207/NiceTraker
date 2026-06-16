import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "saved"]

  connect() {
    this.element.addEventListener("turbo:submit-end", this.onSaved.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.onSaved.bind(this))
  }

  onSaved(event) {
    if (!event.detail.success) return
    if (!this.hasSavedTarget) return
    this.savedTarget.classList.remove("hidden")
    clearTimeout(this._savedTimer)
    this._savedTimer = setTimeout(() => this.savedTarget.classList.add("hidden"), 2000)
  }
}
