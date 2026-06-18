import { Turbo } from "@hotwired/turbo-rails"

Turbo.StreamActions.addClass = function() {
  const classes = (this.getAttribute("classes") || "").split(" ").filter(Boolean)
  this.targetElements.forEach(el => el.classList.add(...classes))
}

Turbo.StreamActions.removeClass = function() {
  const classes = (this.getAttribute("classes") || "").split(" ").filter(Boolean)
  this.targetElements.forEach(el => el.classList.remove(...classes))
}
