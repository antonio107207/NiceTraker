import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startBtn", "stopBtn", "durationInput"]
  static values = { cardId: String }

  connect() {
    this._tick = this._tick.bind(this)
    if (this._isRunning()) {
      this._startDisplay()
    }
  }

  disconnect() {
    this._stopDisplay()
  }

  start() {
    localStorage.setItem(this._key(), Date.now().toString())
    this._startDisplay()
  }

  stop() {
    const elapsed = this._elapsedMinutes()
    localStorage.removeItem(this._key())
    this._stopDisplay()
    if (this.hasDurationInputTarget && elapsed > 0) {
      this.durationInputTarget.value = this._fmt(elapsed)
      this.durationInputTarget.focus()
    }
  }

  _startDisplay() {
    this.startBtnTarget.classList.add("hidden")
    this.stopBtnTarget.classList.remove("hidden")
    this._interval = setInterval(this._tick, 1000)
    this._tick()
  }

  _stopDisplay() {
    clearInterval(this._interval)
    if (this.hasStartBtnTarget) this.startBtnTarget.classList.remove("hidden")
    if (this.hasStopBtnTarget)  this.stopBtnTarget.classList.add("hidden")
    if (this.hasDisplayTarget)  this.displayTarget.textContent = ""
  }

  _tick() {
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = this._fmt(this._elapsedMinutes())
    }
  }

  _isRunning() { return !!localStorage.getItem(this._key()) }

  _elapsedMinutes() {
    const start = parseInt(localStorage.getItem(this._key()) || "0")
    return start ? Math.floor((Date.now() - start) / 60000) : 0
  }

  _key() { return `timer_card_${this.cardIdValue}` }

  _fmt(minutes) {
    const h = Math.floor(minutes / 60), m = minutes % 60
    if (h > 0 && m > 0) return `${h}h ${m}m`
    if (h > 0) return `${h}h`
    return `${m}m`
  }
}
