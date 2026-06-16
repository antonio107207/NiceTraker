import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  closeOnBackdrop(event) {
    if (event.target === this.element) this.close()
  }

  close(event) {
    // Don't close if a form field is focused (e.g. Esc dismissing browser autocomplete)
    const active = document.activeElement
    if (active && (active.tagName === "INPUT" || active.tagName === "TEXTAREA" || active.tagName === "SELECT")) {
      active.blur()
      return
    }
    this.element.closest("turbo-frame").innerHTML = ""
    const board = document.querySelector("[data-board-url]")
    if (board) history.replaceState(null, "", board.dataset.boardUrl)
  }
}
