import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "dropdown",
    "toggleButton",
    "effectSection",
    "selectedCategories",
    "selectedCategoriesList",
  ];

  // Словарь для перевода значений категорий в читаемые названия
  categoryLabels = {
    photoProcessing: "Обработка фото",
    "3dGrafics": "3D-графика",
    motion: "Моушен",
    illustration: "Иллюстрация",
    animation: "Анимация",
    uiux: "UI/UX-анимация",
    videoProcessing: "Обработка видео",
    vfx: "VFX",
    gamedev: "Геймдев",
    arvr: "AR & VR",
  };

  connect() {
    // Закрыть выпадающее меню при клике вне его
    document.addEventListener("click", this.handleOutsideClick.bind(this));

    // Проверяем URL параметры при загрузке страницы
    this.checkUrlParams();
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  }

  toggle(event) {
    event.preventDefault();
    const dropdown = this.dropdownTarget;
    const isVisible = dropdown.style.display !== "none";

    if (isVisible) {
      dropdown.style.display = "none";
    } else {
      dropdown.style.display = "flex";
    }
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.style.display = "none";
    }
  }

  // Новый метод для проверки URL параметров
  checkUrlParams() {
    const urlParams = new URLSearchParams(window.location.search);
    const categoryParam = urlParams.get("category");

    if (categoryParam) {
      console.log("Found category parameter:", categoryParam);

      // Находим соответствующий чекбокс и отмечаем его
      const checkbox = this.element.querySelector(
        `input[value="${categoryParam}"]`
      );
      if (checkbox) {
        checkbox.checked = true;
        console.log("Auto-selected category:", categoryParam);

        // Применяем фильтрацию
        this.filterEffects();

        // Очищаем URL параметр после применения
        this.clearUrlParam();
      } else {
        console.error("Checkbox not found for category:", categoryParam);
      }
    }
  }

  // Метод для очистки URL параметра
  clearUrlParam() {
    const url = new URL(window.location);
    url.searchParams.delete("category");
    window.history.replaceState({}, "", url.toString());
  }

  // Метод для автоматического разворачивания секции категории
  expandCategorySection(categoryName) {
    // Находим контейнер с эффектами для данной категории
    const effectsContainer = document.querySelector(
      `[data-category-name="${categoryName}"]`
    );
    const viewAllButton = document.querySelector(
      `[data-category="${categoryName}"][data-category-target="viewAllButton"]`
    );

    if (effectsContainer && effectsContainer.classList.contains("hidden")) {
      // Убираем класс hidden чтобы показать эффекты
      effectsContainer.classList.remove("hidden");
      console.log(`Expanded category section: ${categoryName}`);
    }

    if (viewAllButton && viewAllButton.classList.contains("hidden")) {
      // Показываем кнопку "Смотреть все"
      viewAllButton.classList.remove("hidden");
    }

    // Поворачиваем стрелочку
    const categoryButton = document.querySelector(
      `.M_HeaderEffectsCategories[data-category="${categoryName}"]`
    );
    if (categoryButton) {
      const arrow = categoryButton.querySelector(".Q_IconArrowBlack");
      if (arrow && !arrow.classList.contains("rotated")) {
        arrow.classList.add("rotated");
        console.log(`Rotated arrow for category: ${categoryName}`);
      }
    } else {
      console.error(`Category button not found for: ${categoryName}`);
    }
  }

  // Новый метод для очистки всех фильтров
  clearAll(event) {
    event.preventDefault();

    // Снимаем все чекбоксы
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach((checkbox) => {
      checkbox.checked = false;
    });

    // Очищаем отображение выбранных категорий
    this.updateSelectedCategoriesDisplay([]);

    // Применяем фильтрацию (покажет все)
    this.filterEffects();
  }

  // Новый метод для удаления отдельной категории
  removeCategory(event) {
    event.preventDefault();

    // Находим кнопку, даже если клик был по изображению внутри кнопки
    const button = event.target.closest("button[data-category]");
    if (!button) {
      console.error("Button with data-category not found");
      return;
    }

    const categoryValue = button.dataset.category;
    console.log("Removing category:", categoryValue);

    // Находим и снимаем соответствующий чекбокс
    const checkbox = this.element.querySelector(
      `input[value="${categoryValue}"]`
    );
    if (checkbox) {
      checkbox.checked = false;
      console.log("Checkbox unchecked for category:", categoryValue);
    } else {
      console.error("Checkbox not found for category:", categoryValue);
    }

    // Обновляем отображение и применяем фильтрацию
    this.filterEffects();
  }

  // Новый метод для обновления отображения выбранных категорий
  updateSelectedCategoriesDisplay(selectedCategories) {
    if (
      !this.hasSelectedCategoriesTarget ||
      !this.hasSelectedCategoriesListTarget
    ) {
      return;
    }

    const container = this.selectedCategoriesTarget;
    const list = this.selectedCategoriesListTarget;

    if (selectedCategories.length === 0) {
      // Скрываем контейнер если нет выбранных категорий
      container.style.display = "none";
      list.innerHTML = "";
    } else {
      // Показываем контейнер
      container.style.display = "flex";

      // Создаем элементы для каждой выбранной категории
      const categoryElements = selectedCategories
        .map((category) => {
          const label = this.categoryLabels[category] || category;
          return `
          <div class="O_SelectedCategoryTag">
            <span>${label}</span>
            <button class="Q_RemoveCategoryButton" data-action="categories-filter#removeCategory" data-category="${category}">
              <img src="/assets/CancelFilter.svg" alt="Удалить" class="Q_CancelFilterIcon">
            </button>
          </div>
        `;
        })
        .join("");

      list.innerHTML = categoryElements;
    }
  }

  filterEffects(event) {
    const selectedCategories = [];
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"]:checked'
    );

    checkboxes.forEach((checkbox) => {
      selectedCategories.push(checkbox.value);
    });

    console.log("Selected categories:", selectedCategories);

    // Обновляем отображение выбранных категорий
    this.updateSelectedCategoriesDisplay(selectedCategories);

    // Показать/скрыть секции на основе выбранных категорий
    this.effectSectionTargets.forEach((section) => {
      const sectionCategory = section.dataset.category;

      if (selectedCategories.length === 0) {
        // Если ничего не выбрано - показать все секции
        section.style.display = "flex";
      } else {
        // При фильтрации показать только секции выбранных категорий
        if (selectedCategories.includes(sectionCategory)) {
          section.style.display = "flex";
          // Автоматически разворачиваем секцию (убираем hidden класс)
          this.expandCategorySection(sectionCategory);
        } else {
          section.style.display = "none";
        }
      }

      // Фильтровать эффекты внутри каждой видимой секции
      if (section.style.display !== "none") {
        const effectCards = section.querySelectorAll(".O_EffectCollectionCard");
        let visibleEffectsCount = 0;

        effectCards.forEach((card) => {
          const effectCategories = card.dataset.categories
            ? card.dataset.categories.split(",")
            : [];

          // Проверить, соответствует ли эффект активному поиску
          const searchInput = document.querySelector(
            '[data-search-categories-target="input"]'
          );
          const searchQuery = searchInput
            ? searchInput.value.trim().toLowerCase()
            : "";
          const effectName = (card.dataset.name || "").toLowerCase();
          const effectDescription = (
            card.dataset.description || ""
          ).toLowerCase();

          const matchesSearch =
            searchQuery === "" ||
            effectName.includes(searchQuery) ||
            effectDescription.includes(searchQuery);

          if (selectedCategories.length === 0) {
            // Если ничего не выбрано - показать все эффекты, которые соответствуют поиску
            if (matchesSearch) {
              card.style.display = "flex";
              visibleEffectsCount++;
            } else {
              card.style.display = "none";
            }
          } else {
            // При фильтрации показать только эффекты, которые принадлежат к выбранным категориям И соответствуют поиску
            const hasMatchingCategory = effectCategories.some((category) =>
              selectedCategories.includes(category)
            );
            if (hasMatchingCategory && matchesSearch) {
              card.style.display = "flex";
              visibleEffectsCount++;
            } else {
              card.style.display = "none";
            }
          }
        });

        // Скрыть секцию, если в ней нет видимых эффектов
        if (visibleEffectsCount === 0) {
          section.style.display = "none";
        }
      }
    });
  }
}
