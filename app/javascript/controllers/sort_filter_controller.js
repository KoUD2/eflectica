import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropdown", "toggleButton", "currentSort", "effectSection"];

  connect() {
    console.log("Sort filter controller connected");
    // Устанавливаем сортировку по умолчанию
    this.currentSortMethod = "newest";
    this.updateActiveButton();
    this.sortEffects();
  }

  toggle() {
    console.log("Toggle sort dropdown");
    const dropdown = this.dropdownTarget;
    const arrow = this.toggleButtonTarget.querySelector(".Q_IconArrowBlack");

    if (dropdown.style.display === "none" || dropdown.style.display === "") {
      dropdown.style.display = "block";
      if (arrow) {
        arrow.classList.add("rotated");
      }
    } else {
      dropdown.style.display = "none";
      if (arrow) {
        arrow.classList.remove("rotated");
      }
    }
  }

  sortByNewest(event) {
    event.preventDefault();
    console.log("Sorting by newest");
    this.currentSortMethod = "newest";
    this.updateCurrentSort("Сначала новые");
    this.updateActiveButton();
    this.sortEffects();
    this.closeDropdown();
  }

  sortByPopular(event) {
    event.preventDefault();
    console.log("Sorting by popular");
    this.currentSortMethod = "popular";
    this.updateCurrentSort("Сначала популярные");
    this.updateActiveButton();
    this.sortEffects();
    this.closeDropdown();
  }

  updateCurrentSort(text) {
    if (this.hasCurrentSortTarget) {
      this.currentSortTarget.textContent = text;
    }
  }

  updateActiveButton() {
    // Убираем активный класс со всех кнопок
    const allButtons = this.element.querySelectorAll(".Q_SortItem");
    allButtons.forEach((button) => {
      button.classList.remove("active");
    });

    // Добавляем активный класс к текущей кнопке
    const activeButton = this.element.querySelector(
      `[data-action*="sortBy${
        this.currentSortMethod === "newest" ? "Newest" : "Popular"
      }"]`
    );
    if (activeButton) {
      activeButton.classList.add("active");
    }
  }

  sortEffects() {
    const effectsContainer = this.effectSectionTarget;
    const effects = Array.from(effectsContainer.children);

    console.log("Sorting effects, method:", this.currentSortMethod);
    console.log("Effects count:", effects.length);

    if (this.currentSortMethod === "newest") {
      effects.sort((a, b) => {
        const dateA = new Date(a.dataset.createdAt || 0);
        const dateB = new Date(b.dataset.createdAt || 0);
        return dateB - dateA; // Новые сначала
      });
    } else if (this.currentSortMethod === "popular") {
      effects.sort((a, b) => {
        const likesA = parseInt(a.dataset.likes || 0);
        const likesB = parseInt(b.dataset.likes || 0);
        return likesB - likesA; // Больше лайков сначала
      });
    }

    // Очищаем контейнер и добавляем отсортированные эффекты
    effectsContainer.innerHTML = "";
    effects.forEach((effect) => {
      effectsContainer.appendChild(effect);
    });

    // Запускаем фильтрацию задач после сортировки, если контроллер задач существует
    this.triggerTaskFilter();
  }

  triggerTaskFilter() {
    // Находим контроллер фильтрации задач и запускаем фильтрацию
    const taskFilterElement = document.querySelector(
      '[data-controller*="task-filter"]'
    );
    if (taskFilterElement) {
      const taskController =
        this.application.getControllerForElementAndIdentifier(
          taskFilterElement,
          "task-filter"
        );
      if (taskController && taskController.filterEffects) {
        // Создаем фиктивное событие для запуска фильтрации
        taskController.filterEffects();
      }
    }
  }

  closeDropdown() {
    this.dropdownTarget.style.display = "none";
    const arrow = this.toggleButtonTarget.querySelector(".Q_IconArrowBlack");
    if (arrow) {
      arrow.classList.remove("rotated");
    }
  }
}
