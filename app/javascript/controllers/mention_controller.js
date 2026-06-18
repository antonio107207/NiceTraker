import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "list"]
  static values  = { members: Array }

  connect() {
    this._query    = ""
    this._triggerPos = -1
  }

  onInput(event) {
    const input = event.target
    const val   = input.value
    const pos   = input.selectionStart

    // Find the nearest @ before the cursor that isn't already closed with ]
    const before = val.slice(0, pos)
    const atIdx  = before.lastIndexOf("@")

    if (atIdx === -1 || before.slice(atIdx).includes("]")) {
      this.hide()
      return
    }

    this._triggerPos = atIdx
    this._query      = before.slice(atIdx + 1).toLowerCase()
    this._input      = input

    const matches = this.membersValue.filter(m =>
      m.toLowerCase().includes(this._query)
    )

    if (matches.length === 0) {
      this.hide()
      return
    }

    this.listTarget.innerHTML = matches.map(name =>
      `<button type="button"
               class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-indigo-50 hover:text-indigo-700 transition-colors"
               data-action="click->mention#select"
               data-name="${this.escape(name)}">${this.escape(name)}</button>`
    ).join("")

    this.dropdownTarget.classList.remove("hidden")
  }

  select(event) {
    const name  = event.currentTarget.dataset.name
    const input = this._input
    const val   = input.value
    const before = val.slice(0, this._triggerPos)
    const after  = val.slice(input.selectionStart)

    input.value           = `${before}@[${name}]${after}`
    input.selectionStart  = input.selectionEnd = this._triggerPos + name.length + 3
    input.focus()
    this.hide()
  }

  onKeydown(event) {
    if (this.dropdownTarget.classList.contains("hidden")) return

    if (event.key === "Escape") {
      this.hide()
      event.preventDefault()
    }
  }

  hide() {
    this.dropdownTarget.classList.add("hidden")
    this._triggerPos = -1
    this._query      = ""
  }

  escape(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }
}
