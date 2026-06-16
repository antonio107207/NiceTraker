import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "form"]

  show() {
    this.toggleTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.formTarget.querySelector("input,textarea")?.focus()
  }

  hide() {
    this.formTarget.classList.add("hidden")
    this.toggleTarget.classList.remove("hidden")
  }

  // After card create, Turbo Stream replaces the form div — reconnecting it
  // triggers this callback, which restores the visible toggle button.
  formTargetConnected() {
    if (this.hasToggleTarget) this.toggleTarget.classList.remove("hidden")
  }
}
