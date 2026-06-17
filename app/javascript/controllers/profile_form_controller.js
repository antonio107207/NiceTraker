import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["newPassword", "currentPasswordSection"]

  onNewPasswordInput() {
    const hasValue = this.newPasswordTargets.some(f => f.value.length > 0)
    this.currentPasswordSectionTarget.classList.toggle("hidden", !hasValue)
  }
}
