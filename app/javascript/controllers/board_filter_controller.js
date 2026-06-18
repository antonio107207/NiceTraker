import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    member: { type: String, default: "" },
    label:  { type: String, default: "" },
    due:    { type: String, default: "" },
  }

  toggle({ currentTarget: btn }) {
    const { filterType, filterValue } = btn.dataset
    const key = `${filterType}Value`
    this[key] = this[key] === filterValue ? "" : filterValue
    this.apply()
    this.syncButtons()
  }

  clearAll() {
    this.memberValue = ""
    this.labelValue  = ""
    this.dueValue    = ""
    this.apply()
    this.syncButtons()
  }

  apply() {
    const member = this.memberValue
    const label  = this.labelValue
    const due    = this.dueValue

    this.element.querySelectorAll("[data-card-id]").forEach(card => {
      const show = this.cardMatches(card, member, label, due)
      card.classList.toggle("!hidden", !show)
    })
  }

  syncButtons() {
    this.element.querySelectorAll("[data-filter-type]").forEach(btn => {
      const active = this[`${btn.dataset.filterType}Value`] === btn.dataset.filterValue
      btn.classList.toggle("ring-2", active)
      btn.classList.toggle("ring-white", active)
    })

    const hasFilter = this.memberValue || this.labelValue || this.dueValue
    const clearBtn = this.element.querySelector("[data-board-filter-clear]")
    if (clearBtn) clearBtn.classList.toggle("hidden", !hasFilter)
  }

  cardMatches(card, member, label, due) {
    if (member) {
      const ids = (card.dataset.memberIds || "").split(",").filter(Boolean)
      if (!ids.includes(member)) return false
    }
    if (label) {
      const ids = (card.dataset.labelIds || "").split(",").filter(Boolean)
      if (!ids.includes(label)) return false
    }
    if (due && card.dataset.dueStatus !== due) return false
    return true
  }
}
