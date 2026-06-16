import { Controller } from "@hotwired/stimulus"

const COLORS = [
  "#6366f1","#8b5cf6","#a855f7","#d946ef","#ec4899",
  "#f43f5e","#ef4444","#f97316","#f59e0b","#eab308",
  "#84cc16","#22c55e","#10b981","#14b8a6","#06b6d4",
  "#0ea5e9","#3b82f6","#64748b","#334155","#1e293b"
]

const GRADIENTS = [
  "linear-gradient(135deg,#667eea 0%,#764ba2 100%)",
  "linear-gradient(135deg,#f093fb 0%,#f5576c 100%)",
  "linear-gradient(135deg,#4facfe 0%,#00f2fe 100%)",
  "linear-gradient(135deg,#43e97b 0%,#38f9d7 100%)",
  "linear-gradient(135deg,#fa709a 0%,#fee140 100%)",
  "linear-gradient(135deg,#a18cd1 0%,#fbc2eb 100%)",
  "linear-gradient(135deg,#fda085 0%,#f6d365 100%)",
  "linear-gradient(135deg,#ff0844 0%,#ffb199 100%)",
  "linear-gradient(135deg,#0f2027 0%,#203a43 60%,#2c5364 100%)",
  "linear-gradient(135deg,#232526 0%,#414345 100%)",
  "linear-gradient(135deg,#005c97 0%,#363795 100%)",
  "linear-gradient(135deg,#134e5e 0%,#71b280 100%)",
]

export default class extends Controller {
  static targets = ["panel","tab","colorInput","removeInput","fileInput","preview","swatchBtn"]

  connect() {
    this._activeTab = this.hasFileInputTarget && this.element.dataset.hasImage === "true" ? "photos" : "colors"
    this._renderPanels()
    this._switchTab(this._activeTab)
  }

  switchTab(e) {
    this._switchTab(e.currentTarget.dataset.tab)
  }

  pickSwatch(e) {
    const val = e.currentTarget.dataset.value
    this.colorInputTarget.value = val
    this.removeInputTarget.value = "1"
    this._clearFile()
    this._updatePreview(val, null)
    this._highlightSwatch(val)
  }

  onFileChange(e) {
    const file = e.target.files[0]
    if (!file) return
    this.colorInputTarget.value = ""
    this.removeInputTarget.value = "0"
    const reader = new FileReader()
    reader.onload = ev => {
      this._updatePreview(null, ev.target.result)
    }
    reader.readAsDataURL(file)
    this._highlightSwatch(null)
  }

  triggerUpload() {
    this.fileInputTarget.click()
  }

  _switchTab(tab) {
    this._activeTab = tab
    this.panelTargets.forEach(p => p.classList.toggle("hidden", p.dataset.panel !== tab))
    this.tabTargets.forEach(t => {
      const active = t.dataset.tab === tab
      t.classList.toggle("bg-white", active)
      t.classList.toggle("shadow-sm", active)
      t.classList.toggle("text-gray-800", active)
      t.classList.toggle("text-gray-500", !active)
    })
  }

  _renderPanels() {
    const colorsPanel = this.panelTargets.find(p => p.dataset.panel === "colors")
    const gradientsPanel = this.panelTargets.find(p => p.dataset.panel === "gradients")
    if (colorsPanel) colorsPanel.innerHTML = this._swatchGrid(COLORS, c => `background-color:${c}`)
    if (gradientsPanel) gradientsPanel.innerHTML = this._swatchGrid(GRADIENTS, g => `background:${g}`)
    this._highlightSwatch(this.colorInputTarget.value)
  }

  _swatchGrid(values, styleFn) {
    return `<div class="grid grid-cols-5 gap-2 p-1">${values.map(v =>
      `<button type="button"
        class="swatch w-10 h-10 rounded-lg transition-all hover:scale-110 focus:outline-none"
        style="${styleFn(v)}"
        data-action="click->bg-picker#pickSwatch"
        data-value="${v}"></button>`
    ).join("")}</div>`
  }

  _highlightSwatch(val) {
    this.element.querySelectorAll(".swatch").forEach(s => {
      const selected = val && s.dataset.value === val
      s.style.outline = selected ? "3px solid white" : ""
      s.style.outlineOffset = selected ? "2px" : ""
      s.style.transform = selected ? "scale(1.15)" : ""
      s.style.boxShadow = selected ? "0 0 0 2px #6366f1" : ""
    })
  }

  _updatePreview(colorOrGradient, imageUrl) {
    const preview = this.previewTarget
    if (imageUrl) {
      preview.style.backgroundImage = `url(${imageUrl})`
      preview.style.backgroundSize = "cover"
      preview.style.backgroundPosition = "center"
      preview.style.background = ""
    } else if (colorOrGradient) {
      preview.style.backgroundImage = ""
      if (colorOrGradient.includes("gradient")) {
        preview.style.background = colorOrGradient
      } else {
        preview.style.backgroundColor = colorOrGradient
        preview.style.backgroundImage = ""
      }
    }
  }

  _clearFile() {
    if (this.hasFileInputTarget) this.fileInputTarget.value = ""
  }
}
