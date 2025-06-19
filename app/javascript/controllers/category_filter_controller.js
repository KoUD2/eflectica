import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropdown", "toggleButton", "effectSection"];

  connect() {
    // Закрыть выпадающее меню при клике вне его
    document.addEventListener("click", this.handleOutsideClick.bind(this));

    // Инициализация - показать только базовые секции
    this.initializeView();
  }

  initializeView() {
    this.effectSectionTargets.forEach((section) => {
      const sectionCategory = section.dataset.category;
      const defaultSections = ["photoProcessing", "3dGrafics", "motion"];

      if (defaultSections.includes(sectionCategory)) {
        section.style.display = "flex";
        // Показать все эффекты в базовых секциях
        const effectCards = section.querySelectorAll(".O_EffectCollectionCard");
        effectCards.forEach((card) => {
          card.style.display = "flex";
        });
      } else {
        section.style.display = "none";
      }
    });
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

  filterEffects(event) {
    const selectedCategories = [];
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"]:checked'
    );

    checkboxes.forEach((checkbox) => {
      selectedCategories.push(checkbox.value);
    });

    console.log("Selected categories:", selectedCategories);

    // Отладка: показать все эффекты с их категориями
    const allEffectCards = document.querySelectorAll(".O_EffectCollectionCard");
    console.log(`Total effect cards found: ${allEffectCards.length}`);
    allEffectCards.forEach((card, index) => {
      const effectCategories = card.dataset.categories
        ? card.dataset.categories.split(",")
        : [];
      console.log(
        `Effect ${index + 1}: "${
          card.dataset.name
        }" has categories: [${effectCategories.join(", ")}]`
      );
    });

    // Показать/скрыть секции на основе выбранных категорий
    console.log(
      "Available sections:",
      this.effectSectionTargets.map((s) => s.dataset.category)
    );
    this.effectSectionTargets.forEach((section) => {
      const sectionCategory = section.dataset.category;
      console.log("Processing section:", sectionCategory);

      if (selectedCategories.length === 0) {
        // Если ничего не выбрано - показать только основные 3 секции
        const defaultSections = ["photoProcessing", "3dGrafics", "motion"];
        if (defaultSections.includes(sectionCategory)) {
          section.style.display = "flex";
          console.log("Showing default section:", sectionCategory);
        } else {
          section.style.display = "none";
          console.log("Hiding non-default section:", sectionCategory);
        }
      } else {
        // При фильтрации показать секции выбранных категорий
        if (selectedCategories.includes(sectionCategory)) {
          section.style.display = "flex";
          console.log("Showing filtered section:", sectionCategory);
        } else {
          section.style.display = "none";
          console.log("Hiding filtered section:", sectionCategory);
        }
      }

      // Фильтровать эффекты внутри каждой видимой секции
      if (section.style.display !== "none") {
        const effectCards = section.querySelectorAll(".O_EffectCollectionCard");
        console.log(
          `Found ${effectCards.length} effect cards in section ${sectionCategory}`
        );

        let visibleEffectsCount = 0;

        effectCards.forEach((card) => {
          const effectCategories = card.dataset.categories
            ? card.dataset.categories.split(",")
            : [];
          console.log(
            "Effect categories:",
            effectCategories,
            "for card:",
            card.dataset.name
          );

          // Проверить, соответствует ли эффект активному поиску
          const searchInput = document.querySelector(
            '[data-search-effects-target="input"]'
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

          console.log(
            `Card ${card.dataset.name}: searchQuery="${searchQuery}", matchesSearch=${matchesSearch}`
          );

          if (selectedCategories.length === 0) {
            // Если ничего не выбрано - показать все эффекты в видимых секциях, которые соответствуют поиску
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
            console.log(
              `Effect "${
                card.dataset.name
              }": effectCategories=[${effectCategories.join(
                ","
              )}], hasMatchingCategory=${hasMatchingCategory}, matchesSearch=${matchesSearch}`
            );
            if (hasMatchingCategory && matchesSearch) {
              card.style.display = "flex";
              visibleEffectsCount++;
              console.log(`✅ Showing effect: ${card.dataset.name}`);
            } else {
              card.style.display = "none";
              console.log(
                `❌ Hiding effect: ${card.dataset.name} (hasMatchingCategory=${hasMatchingCategory}, matchesSearch=${matchesSearch})`
              );
            }
          }
        });

        // Скрыть секцию, если в ней нет видимых эффектов
        if (visibleEffectsCount === 0) {
          section.style.display = "none";
          console.log(
            `🚫 Hiding section ${sectionCategory} - no visible effects`
          );
        } else {
          console.log(
            `✅ Section ${sectionCategory} has ${visibleEffectsCount} visible effects`
          );
        }
      }
    });
  }
}
