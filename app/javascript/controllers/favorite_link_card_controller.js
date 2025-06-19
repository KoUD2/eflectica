import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Favorite link card controller connected");
  }

  open(event) {
    event.preventDefault();

    // Получаем данные из data-атрибутов
    const title = this.element.dataset.linkTitle;
    const url = this.element.dataset.linkUrl;
    const notes = this.element.dataset.linkNotes;
    const linkId = this.element.dataset.linkId;

    // Для избранного всегда используем "favorites" как collection ID
    const collectionId = "favorites";

    // Находим модальное окно и его контроллер
    const modal = document.querySelector(
      '[data-controller*="favorite-link-preview"]'
    );
    if (modal) {
      const controller = this.application.getControllerForElementAndIdentifier(
        modal,
        "favorite-link-preview"
      );
      if (controller) {
        controller.open(title, url, notes, linkId, collectionId);
      }
    }
  }
}
