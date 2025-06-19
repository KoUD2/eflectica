import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radio"];

  connect() {
    // Добавляем курсор pointer для всех M_Choice элементов
    this.element.style.cursor = "pointer";
  }

  click(event) {
    // Предотвращаем двойное срабатывание, если клик был по input элементу, label или checkmark
    if (
      event.target.type === "radio" ||
      event.target.type === "checkbox" ||
      event.target.tagName === "LABEL" ||
      event.target.className.includes("checkmark")
    ) {
      return;
    }

    // Сначала ищем radio button
    const radioButton = this.element.querySelector('input[type="radio"]');
    if (radioButton && !radioButton.checked) {
      radioButton.checked = true;
      // Диспатчим событие change для совместимости с другими обработчиками
      radioButton.dispatchEvent(new Event("change", { bubbles: true }));
      return;
    }

    // Если radio button не найден, ищем checkbox
    const checkbox = this.element.querySelector('input[type="checkbox"]');
    if (checkbox) {
      checkbox.checked = !checkbox.checked;
      // Диспатчим событие change для совместимости с другими обработчиками
      checkbox.dispatchEvent(new Event("change", { bubbles: true }));
    }
  }
}
