import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.element.addEventListener("ajax:success", (event) => {
      const [data] = event.detail
      this.updateButton(data.status)
    })
  }

  updateButton(status) {
    const button = this.element
    if (button.classList.contains('A_SubscribeButton')) {
      button.innerHTML = `
        <button class="A_ButtonSecondary A_SubscribeButton>
          <img src="/assets/Minus.svg" class="A_folowCollectionImage" alt="Удалить подписку">
          <p class='Q_ButtonSecondary Q_ButtonSecondaryDark'>Отписаться</p>
        </button>
      `
      button.action = '/collections/${button.dataset.collectionId}/unsubscribe'
      button.method = 'delete'
    } else {
      button.innerHTML = `
        <button class="A_ButtonSecondary A_UnsubscribeButton>
          <img src="assets/Plus-65a8d56534258fb1…e79d36d8b8657612181641c3c3ba7f3db4a5d65d06ac2.svg" class="A_folowCollectionImage" alt="Подписаться">
          <p class='Q_ButtonSecondary'>Подписаться</p>
        </button>
      `
      button.action = '/collections/${button.dataset.collectionId}/subscribe'
      button.method = 'post'
    }
  }
}
