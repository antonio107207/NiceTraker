import { Controller } from "@hotwired/stimulus"

// Inline text editing (single line — for list/card titles)
export default class extends Controller {
  static values = { url: String, field: String }

  connect() {
    this.element.setAttribute("contenteditable", "true")
    this.original = this.element.textContent.trim()
    this.element.addEventListener("blur",    this.save.bind(this))
    this.element.addEventListener("keydown", this.onKey.bind(this))
  }

  onKey(e) {
    if (e.key === "Enter") { e.preventDefault(); this.element.blur() }
    if (e.key === "Escape") { this.element.textContent = this.original; this.element.blur() }
  }

  save() {
    const value = this.element.textContent.trim()
    if (value === this.original || !value) return
    this.original = value
    fetch(this.urlValue, {
      method:  "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content },
      body:    JSON.stringify({ [this.fieldValue.split("[")[0]]: { [this.fieldValue.match(/\[(.+)\]/)?.[1]]: value } })
    })
  }
}
