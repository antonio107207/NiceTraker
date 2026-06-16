import Sortable from "sortablejs"

function csrf() {
  return document.querySelector('meta[name="csrf-token"]')?.content
}

function patch(url, body) {
  fetch(url, {
    method: "PATCH",
    headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf() },
    body: JSON.stringify(body)
  })
}

function initDrag() {
  const listsEl = document.getElementById("lists_container")
  if (!listsEl) return

  // Destroy any existing instances to avoid duplicates
  if (listsEl._sortable) listsEl._sortable.destroy()
  listsEl._sortable = Sortable.create(listsEl, {
    group:      { name: "lists", pull: true, put: ["lists"] },
    draggable:  "[data-list-id]",
    handle:     "[data-list-drag-handle]",
    animation:  150,
    ghostClass: "sortable-ghost",
    dragClass:  "shadow-2xl",
    onEnd({ item, newIndex }) {
      patch(`/lists/${item.dataset.listId}/move`, { position: newIndex + 1 })
    }
  })

  document.querySelectorAll("[data-cards-list]").forEach(el => {
    if (el._sortable) el._sortable.destroy()
    el._sortable = Sortable.create(el, {
      group:      { name: "cards", pull: true, put: ["cards"] },
      draggable:  "[data-card-id]",
      animation:  150,
      ghostClass: "sortable-ghost",
      dragClass:  "shadow-2xl",
      onEnd({ item, newIndex, to }) {
        patch(`/cards/${item.dataset.cardId}/move`, {
          position: newIndex + 1,
          list_id:  to.dataset.listId
        })
      }
    })
  })
}

document.addEventListener("turbo:load", initDrag)

// turbo:stream-render doesn't exist in Turbo 8 — intercept the render function instead
// so initDrag runs after each stream action updates the DOM
document.addEventListener("turbo:before-stream-render", (event) => {
  const originalRender = event.detail.render
  event.detail.render = async (streamElement) => {
    await originalRender(streamElement)
    initDrag()
  }
})
