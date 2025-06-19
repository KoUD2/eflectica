import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Favorite reference card controller connected");
  }

  openModal(event) {
    event.preventDefault();

    // Находим модальное окно и его контроллер
    const modal = document.querySelector(
      '[data-controller*="favorite-reference-preview"]'
    );
    if (modal) {
      const controller = this.application.getControllerForElementAndIdentifier(
        modal,
        "favorite-reference-preview"
      );
      if (controller) {
        controller.openModal(event);
      }
    }
  }
}
