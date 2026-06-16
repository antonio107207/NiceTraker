import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "chevron"]
  static values = { open: { type: Boolean, default: true } }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    if (!this.hasContentTarget) return
    this.contentTarget.classList.toggle("hidden", !this.openValue)
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = this.openValue ? "" : "rotate(-90deg)"
    }
  }
}
