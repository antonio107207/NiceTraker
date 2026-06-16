import { Controller } from "@hotwired/stimulus"

const KEY   = "nt-theme"
const MODES = ["auto", "light", "dark"]

const ICONS = {
  auto: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>`,
  light: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px"><circle cx="12" cy="12" r="4"/><line x1="12" y1="2" x2="12" y2="6"/><line x1="12" y1="18" x2="12" y2="22"/><line x1="4.93" y1="4.93" x2="7.76" y2="7.76"/><line x1="16.24" y1="16.24" x2="19.07" y2="19.07"/><line x1="2" y1="12" x2="6" y2="12"/><line x1="18" y1="12" x2="22" y2="12"/><line x1="4.93" y1="19.07" x2="7.76" y2="16.24"/><line x1="16.24" y1="7.76" x2="19.07" y2="4.93"/></svg>`,
  dark: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>`,
}

const TITLES = { auto: "Auto (system)", light: "Light", dark: "Dark" }

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
    const mode = this.current
    const dark = mode === "dark" || (mode === "auto" && this.mql.matches)
    document.documentElement.classList.toggle("dark", dark)
    this.iconTargets.forEach(el => {
      el.innerHTML = ICONS[mode]
      const btn = el.closest("button") || el
      btn.title = TITLES[mode]
    })
  }

  get current() {
    return localStorage.getItem(KEY) || "auto"
  }
}
