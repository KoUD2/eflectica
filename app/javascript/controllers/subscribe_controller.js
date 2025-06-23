import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { collectionId: String };

  connect() {
    console.log(
      "Subscribe controller connected for collection:",
      this.collectionIdValue
    );
  }

  async subscribe(event) {
    event.preventDefault();

    const button = event.currentTarget;
    const url = button.dataset.subscribeUrl;

    if (!url) {
      console.error("Subscribe URL not found");
      return;
    }

    // Блокируем кнопку на время запроса
    button.disabled = true;
    const originalText = button.innerHTML;
    button.innerHTML = "Подписываемся...";

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
          Accept: "application/json",
        },
      });

      const data = await response.json();

      if (response.ok) {
        this.handleSuccess(data);
      } else {
        this.handleError(data);
      }
    } catch (error) {
      console.error("Subscribe error:", error);
    } finally {
      // Разблокируем кнопку
      button.disabled = false;
      button.innerHTML = originalText;
    }
  }

  async unsubscribe(event) {
    event.preventDefault();

    const button = event.currentTarget;
    const url = button.dataset.subscribeUrl;

    if (!url) {
      console.error("Unsubscribe URL not found");
      return;
    }

    // Блокируем кнопку на время запроса
    button.disabled = true;
    const originalText = button.innerHTML;
    button.innerHTML = "Отписываемся...";

    try {
      const response = await fetch(url, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
          Accept: "application/json",
        },
      });

      const data = await response.json();

      if (response.ok) {
        this.handleSuccess(data);
      } else {
        this.handleError(data);
      }
    } catch (error) {
      console.error("Unsubscribe error:", error);
    } finally {
      // Разблокируем кнопку
      button.disabled = false;
      button.innerHTML = originalText;
    }
  }

  handleSuccess(data) {
    console.log("Subscribe success:", data);

    if (data && data.html) {
      this.updateButtonContent(data.html);
    }
  }

  handleError(data) {
    console.log("Subscribe error:", data);

    if (data && data.html) {
      this.updateButtonContent(data.html);
    }
  }

  updateButtonContent(html) {
    const turboFrame = this.element.querySelector("turbo-frame");
    if (turboFrame && html) {
      // Создаем временный элемент для парсинга HTML
      const tempDiv = document.createElement("div");
      tempDiv.innerHTML = html;

      // Ищем новый turbo-frame в ответе
      const newFrame = tempDiv.querySelector("turbo-frame");
      if (newFrame) {
        turboFrame.innerHTML = newFrame.innerHTML;
      }
    }
  }
}
