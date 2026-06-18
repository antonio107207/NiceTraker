import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static values = { manual: { type: Boolean, default: false } }

  connect() {
    this._outsideClick = this._outsideClick.bind(this)
    this._escKey       = this._escKey.bind(this)
  }

  disconnect() {
    this._removeListeners()
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    if (!this.manualValue) {
      // setTimeout avoids catching the toggle click itself
      setTimeout(() => this._addListeners(), 0)
    }
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this._removeListeners()
  }

  get isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }

  _addListeners() {
    document.addEventListener("click",   this._outsideClick)
    document.addEventListener("keydown", this._escKey)
  }

  _removeListeners() {
    document.removeEventListener("click",   this._outsideClick)
    document.removeEventListener("keydown", this._escKey)
  }

  _outsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  _escKey(event) {
    if (event.key === "Escape") this.close()
  }
}
