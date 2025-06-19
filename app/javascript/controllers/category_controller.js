import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["effectsItem", "viewAllButton"];

  connect() {
    // Инициализация состояния для режима выбора эффектов
    this.initializeOpenCategories();
  }

  initializeOpenCategories() {
    // Проверяем, есть ли параметр collection_id в URL
    const urlParams = new URLSearchParams(window.location.search);
    const collectionId = urlParams.get("collection_id");

    if (collectionId) {
      // В режиме выбора эффектов первые 3 категории открыты по умолчанию
      const openCategories = this.effectsItemTargets.slice(0, 3);

      openCategories.forEach((effectsList) => {
        if (!effectsList.classList.contains("hidden")) {
          const category = effectsList.dataset.categoryName;
          const viewAllBtn = this.viewAllButtonTargets.find(
            (btn) => btn.dataset.category === category
          );
          const categoryButton = document.querySelector(
            `[data-category="${category}"]`
          );

          if (viewAllBtn) {
            viewAllBtn.classList.remove("hidden");
          }

          if (categoryButton) {
            const arrow = categoryButton.querySelector(".Q_IconArrowBlack");
            if (arrow) {
              arrow.classList.add("rotated");
            }
          }
        }
      });
    }
  }

  toggle(event) {
    const category = event.currentTarget.dataset.category;
    const effectsList = this.effectsItemTargets.find(
      (el) => el.dataset.categoryName === category
    );
    const viewAllBtn = this.viewAllButtonTargets.find(
      (btn) => btn.dataset.category === category
    );

    if (!effectsList || !viewAllBtn) {
      console.error(`Elements not found for category: ${category}`);
      return;
    }

    effectsList.classList.toggle("hidden");
    viewAllBtn.classList.toggle(
      "hidden",
      effectsList.classList.contains("hidden")
    );
    this.toggleArrowIcon(event.currentTarget);
  }

  toggleArrowIcon(button) {
    const arrow = button.querySelector(".Q_IconArrowBlack");
    arrow.classList.toggle("rotated");
  }
}
