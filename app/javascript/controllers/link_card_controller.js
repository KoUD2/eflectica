import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Link card controller connected");
  }

  open(event) {
    event.preventDefault();

    // Получаем данные из data-атрибутов
    const title = this.element.dataset.linkTitle;
    const url = this.element.dataset.linkUrl;
    const notes = this.element.dataset.linkNotes;
    const linkId = this.element.dataset.linkId;

    // Получаем ID коллекции из родительского элемента
    const collectionElement = document.querySelector("[data-collection-id]");
    const collectionId = collectionElement
      ? collectionElement.dataset.collectionId
      : null;

    // Находим модальное окно и его контроллер
    const modal = document.querySelector('[data-controller*="link-preview"]');
    if (modal) {
      const controller = this.application.getControllerForElementAndIdentifier(
        modal,
        "link-preview"
      );
      if (controller) {
        controller.open(title, url, notes, linkId, collectionId);
      }
    }
  }
}
