import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popup"];

  open() {
    const popupBackdrop = document.body.getElementsByClassName('popup-backdrop')[0]
    this.popupTarget.classList.remove("hidden");
    document.body.style.overflow = 'hidden'
    popupBackdrop.classList.remove('hidden')
  }

  close() {
    const popupBackdrop = document.body.getElementsByClassName('popup-backdrop')[0]
    popupBackdrop.classList.add('hidden')
  document.body.style.overflow = ''
    this.popupTarget.classList.add("hidden");
  }

  toggleFavorite(event) {
    const checkbox = event.target;
    const effectId = this.element.dataset.popupEffectId;

    if (checkbox.checked) {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

      fetch("/favorites", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({ effect_id: effectId }),
      })
        .then((response) => {
          if (response.ok) {
            console.log("Effect added to favorites");
          } else {
            console.error("Failed to add effect to favorites");
          }
        })
        .catch((error) => console.error("Error:", error));
    } else {
      console.log("Effect removed from favorites");
    }
  }

  toggleCollection(event) {
    const checkbox = event.target;
    const collectionId = checkbox.value;
    const effectId = this.element.dataset.popupEffectId;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    if (checkbox.checked) {
      fetch("/collection_effects", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({ 
          collection_id: collectionId,
          effect_id: effectId 
        }),
      })
        .then((response) => {
          if (response.ok) {
            console.log("Effect added to collection");
          } else {
            console.error("Failed to add effect to collection");
          }
        })
        .catch((error) => console.error("Error:", error));
    } else {
      fetch(`/collection_effects/${collectionId}/${effectId}`, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrfToken,
        }
      })
        .then((response) => {
          if (response.ok) {
            console.log("Effect removed from collection");
          } else {
            console.error("Failed to remove effect from collection");
          }
        })
        .catch((error) => console.error("Error:", error));
    }
  }
}
