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
    console.log("Categories page search query:", searchQuery);

    // Найти контроллер categories-filter и вызвать его метод фильтрации
    const categoriesFilterElement = document.querySelector(
      '[data-controller*="categories-filter"]'
    );
    if (categoriesFilterElement) {
      const categoriesController =
        this.application.getControllerForElementAndIdentifier(
          categoriesFilterElement,
          "categories-filter"
        );
      if (categoriesController) {
        categoriesController.filterEffects();
      }
    }
  }

  // Метод для очистки поиска (может быть вызван извне)
  clearSearch() {
    this.inputTarget.value = "";
    this.performSearch("");
  }
}
