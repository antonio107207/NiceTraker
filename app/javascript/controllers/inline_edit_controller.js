import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["view", "form"]

  edit() {
    this.viewTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.formTarget.querySelector("textarea, input:not([type=hidden])")?.focus()
  }

  cancel() {
    this.formTarget.classList.add("hidden")
    this.viewTarget.classList.remove("hidden")
  }
}
