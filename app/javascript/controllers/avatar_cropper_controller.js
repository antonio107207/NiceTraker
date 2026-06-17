import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "initials", "modal", "canvas"]

  connect() {
    this.img = null
    this.offsetX = 0
    this.offsetY = 0
    this.scale = 1
    this.dragStart = null
    this.pinchDist = null
    this.pinchScale = null
  }

  canvasTargetConnected(canvas) {
    this._onMousedown = (e) => this.pointerDown(e)
    this._onMousemove = (e) => this.pointerMove(e)
    this._onMouseup = () => this.pointerUp()
    this._onWheel = (e) => this.onWheel(e)
    this._onTouchstart = (e) => this.pointerDown(e)
    this._onTouchmove = (e) => this.pointerMove(e)
    this._onTouchend = () => this.pointerUp()

    canvas.addEventListener("mousedown", this._onMousedown)
    canvas.addEventListener("mousemove", this._onMousemove)
    canvas.addEventListener("mouseup", this._onMouseup)
    canvas.addEventListener("mouseleave", this._onMouseup)
    canvas.addEventListener("wheel", this._onWheel, { passive: false })
    canvas.addEventListener("touchstart", this._onTouchstart, { passive: true })
    canvas.addEventListener("touchmove", this._onTouchmove, { passive: false })
    canvas.addEventListener("touchend", this._onTouchend, { passive: true })
  }

  canvasTargetDisconnected(canvas) {
    canvas.removeEventListener("mousedown", this._onMousedown)
    canvas.removeEventListener("mousemove", this._onMousemove)
    canvas.removeEventListener("mouseup", this._onMouseup)
    canvas.removeEventListener("mouseleave", this._onMouseup)
    canvas.removeEventListener("wheel", this._onWheel)
    canvas.removeEventListener("touchstart", this._onTouchstart)
    canvas.removeEventListener("touchmove", this._onTouchmove)
    canvas.removeEventListener("touchend", this._onTouchend)
  }

  openPicker() {
    this.inputTarget.click()
  }

  onFileChange(e) {
    const file = e.target.files[0]
    if (!file) return

    const img = new Image()
    img.onload = () => {
      this.img = img
      this.initTransform()
      this.modalTarget.classList.remove("hidden")
      this.draw()
    }
    img.src = URL.createObjectURL(file)
  }

  initTransform() {
    const R = this.cropRadius
    const S = this.canvasTarget.width
    this.scale = (R * 2) / Math.min(this.img.naturalWidth, this.img.naturalHeight)
    this.offsetX = S / 2 - (this.img.naturalWidth * this.scale) / 2
    this.offsetY = S / 2 - (this.img.naturalHeight * this.scale) / 2
  }

  draw() {
    const canvas = this.canvasTarget
    const ctx = canvas.getContext("2d")
    const S = canvas.width
    const R = this.cropRadius
    const cx = S / 2
    const cy = S / 2

    ctx.clearRect(0, 0, S, S)

    ctx.drawImage(
      this.img,
      this.offsetX,
      this.offsetY,
      this.img.naturalWidth * this.scale,
      this.img.naturalHeight * this.scale
    )

    // Dark overlay with circular hole (evenodd removes the circle area)
    ctx.fillStyle = "rgba(0,0,0,0.55)"
    ctx.beginPath()
    ctx.rect(0, 0, S, S)
    ctx.arc(cx, cy, R, 0, Math.PI * 2, true)
    ctx.fill("evenodd")

    // White border ring
    ctx.strokeStyle = "rgba(255,255,255,0.8)"
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.arc(cx, cy, R, 0, Math.PI * 2)
    ctx.stroke()
  }

  get cropRadius() {
    return this.canvasTarget.width / 2 - 10
  }

  toCanvasPoint(e) {
    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()
    const src = e.touches?.[0] ?? e
    return {
      x: (src.clientX - rect.left) * (canvas.width / rect.width),
      y: (src.clientY - rect.top) * (canvas.height / rect.height),
    }
  }

  pointerDown(e) {
    if (e.touches?.length === 2) {
      this.pinchDist = Math.hypot(
        e.touches[0].clientX - e.touches[1].clientX,
        e.touches[0].clientY - e.touches[1].clientY
      )
      this.pinchScale = this.scale
      return
    }
    const pt = this.toCanvasPoint(e)
    this.dragStart = { x: pt.x - this.offsetX, y: pt.y - this.offsetY }
  }

  pointerMove(e) {
    e.preventDefault()
    if (e.touches?.length === 2 && this.pinchDist !== null) {
      const dist = Math.hypot(
        e.touches[0].clientX - e.touches[1].clientX,
        e.touches[0].clientY - e.touches[1].clientY
      )
      this.scale = Math.max(0.1, this.pinchScale * (dist / this.pinchDist))
      this.draw()
      return
    }
    if (this.dragStart === null) return
    const pt = this.toCanvasPoint(e)
    this.offsetX = pt.x - this.dragStart.x
    this.offsetY = pt.y - this.dragStart.y
    this.draw()
  }

  pointerUp() {
    this.dragStart = null
    this.pinchDist = null
    this.pinchScale = null
  }

  onWheel(e) {
    e.preventDefault()
    this.scale = Math.max(0.1, this.scale + (e.deltaY > 0 ? -0.05 : 0.05))
    this.draw()
  }

  apply() {
    const SIZE = 512
    const out = document.createElement("canvas")
    out.width = SIZE
    out.height = SIZE
    const ctx = out.getContext("2d")

    const R = this.cropRadius
    const S = this.canvasTarget.width
    const factor = SIZE / (R * 2)
    const originX = S / 2 - R
    const originY = S / 2 - R

    ctx.drawImage(
      this.img,
      (this.offsetX - originX) * factor,
      (this.offsetY - originY) * factor,
      this.img.naturalWidth * this.scale * factor,
      this.img.naturalHeight * this.scale * factor
    )

    out.toBlob(
      (blob) => {
        const file = new File([blob], "avatar.jpg", { type: "image/jpeg" })
        const dt = new DataTransfer()
        dt.items.add(file)
        this.inputTarget.files = dt.files

        const url = URL.createObjectURL(blob)
        this.previewTarget.src = url
        this.previewTarget.classList.remove("hidden")
        if (this.hasInitialsTarget) this.initialsTarget.classList.add("hidden")

        this.closeModal()
      },
      "image/jpeg",
      0.92
    )
  }

  cancel() {
    this.inputTarget.value = ""
    this.closeModal()
  }

  closeModal() {
    this.modalTarget.classList.add("hidden")
  }
}
