import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"];

  open() {
    this.modalTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  close() {
    this.modalTarget.classList.add("hidden");
    document.body.style.overflow = "auto";
  }

  // Закрытие модального окна при клике на фон
  connect() {
    // Добавляем обработчик события только если modalTarget существует
    if (this.hasModalTarget) {
      this.modalTarget.addEventListener("click", (event) => {
        if (event.target === this.modalTarget) {
          this.close();
        }
      });
    }
  }
}
