import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [];

  openPreview(event) {
    event.preventDefault();

    const imageId = this.element.dataset.imageId;
    const collectionId = this.element.dataset.collectionId;

    console.log("Клик по референсу:", imageId, collectionId);

    // Используем более простой подход - ищем элемент напрямую
    const previewElement = document.querySelector(
      '[data-controller*="reference-preview"]'
    );

    if (previewElement) {
      const previewController =
        this.application.getControllerForElementAndIdentifier(
          previewElement,
          "reference-preview"
        );

      if (previewController) {
        console.log("Контроллер найден, открываем модальное окно");
        // Создаем временный элемент с данными для передачи
        const tempElement = document.createElement("div");
        tempElement.dataset.imageId = imageId;
        tempElement.dataset.collectionId = collectionId;

        const tempEvent = { currentTarget: tempElement };
        previewController.openModal(tempEvent);
      } else {
        console.error("Reference preview controller не найден");
      }
    } else {
      console.error("Reference preview элемент не найден");
    }
  }
}
