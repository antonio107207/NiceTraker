import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => this.dismiss(), 5000)
  }

  dismiss() {
    this.element.querySelectorAll("[data-flash-target='message']").forEach(el => {
      el.style.opacity = "0"
      el.style.transition = "opacity 0.3s"
      setTimeout(() => el.remove(), 300)
    })
  }
}
