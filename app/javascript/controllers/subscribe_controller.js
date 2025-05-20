import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    console.log("Subscribe controller connected");
  }

  updateButton(event) {
    event.preventDefault();
    const [data] = event.detail;
    console.log("Ajax success:", data);

    // Обновление DOM элемента на странице
    const subscriptionButton = document.getElementById("subscription_button");
    if (subscriptionButton) {
      // Преобразовать строку в HTML элементы
      const tempDiv = document.createElement("div");
      tempDiv.innerHTML = data.html || "";

      // Заменить текущий контент
      if (tempDiv.firstChild) {
        subscriptionButton.innerHTML = tempDiv.innerHTML;
      }
    }
  }
}
