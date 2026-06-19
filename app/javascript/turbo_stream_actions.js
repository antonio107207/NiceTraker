import { Turbo } from "@hotwired/turbo-rails"

Turbo.StreamActions.redirect = function() {
  Turbo.visit(this.getAttribute("target"))
}

Turbo.StreamActions.addClass = function() {
  const classes = (this.getAttribute("classes") || "").split(" ").filter(Boolean)
  this.targetElements.forEach(el => el.classList.add(...classes))
}

Turbo.StreamActions.removeClass = function() {
  const classes = (this.getAttribute("classes") || "").split(" ").filter(Boolean)
  this.targetElements.forEach(el => el.classList.remove(...classes))
}
