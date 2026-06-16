import { Controller } from "@hotwired/stimulus"

const KEY    = "nt-theme"
const MODES  = ["auto", "light", "dark"]
const LABELS = { auto: "🖥", light: "☀️", dark: "🌙" }

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.mql = window.matchMedia("(prefers-color-scheme: dark)")
    this.mqlHandler = () => { if (this.current === "auto") this._apply() }
    this.mql.addEventListener("change", this.mqlHandler)
    this._apply()
  }

  disconnect() {
    this.mql?.removeEventListener("change", this.mqlHandler)
  }

  cycle() {
    const next = MODES[(MODES.indexOf(this.current) + 1) % MODES.length]
    localStorage.setItem(KEY, next)
    this._apply()
  }

  _apply() {
    const dark = this.current === "dark" ||
                 (this.current === "auto" && this.mql.matches)
    document.documentElement.classList.toggle("dark", dark)
    this.iconTargets.forEach(el => { el.textContent = LABELS[this.current] })
  }

  get current() {
    return localStorage.getItem(KEY) || "auto"
  }
}
