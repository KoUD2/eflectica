import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    // Дебаунс для оптимизации поиска
    this.searchTimeout = null;
  }

  search(event) {
    // Очистить предыдущий таймаут
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout);
    }

    // Добавить дебаунс для избежания слишком частых поисков
    this.searchTimeout = setTimeout(() => {
      this.performSearch(event.target.value.trim().toLowerCase());
    }, 300);
  }

  performSearch(searchQuery) {
    console.log("Search query:", searchQuery);

    // Найти контроллер категорий и вызвать его метод фильтрации
    const categoryFilterElement = document.querySelector(
      '[data-controller*="category-filter"]'
    );
    if (categoryFilterElement) {
      const categoryController =
        this.application.getControllerForElementAndIdentifier(
          categoryFilterElement,
          "category-filter"
        );
      if (categoryController) {
        categoryController.filterEffects();
      }
    }
  }

  // Метод для очистки поиска (может быть вызван извне)
  clearSearch() {
    this.inputTarget.value = "";
    this.performSearch("");
  }
}
