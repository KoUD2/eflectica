import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchInput", "effectsContainer", "noResults"];

  connect() {
    console.log("Feed search controller connected");
    // Сохраняем все эффекты при загрузке страницы
    this.allEffects = Array.from(this.effectsContainerTarget.children);
  }

  search() {
    const query = this.searchInputTarget.value.toLowerCase().trim();

    console.log("Searching for:", query);

    if (query === "") {
      // Если поиск пустой, показываем все эффекты
      this.showAllEffects();
    } else {
      // Фильтруем эффекты по запросу
      this.filterEffects(query);
    }
  }

  showAllEffects() {
    this.allEffects.forEach((effect) => {
      effect.style.display = "flex";
    });
    this.hideNoResults();
    console.log("Showing all effects");
  }

  filterEffects(query) {
    let visibleCount = 0;

    this.allEffects.forEach((effect) => {
      const effectName = this.getEffectName(effect);
      const effectDescription = this.getEffectDescription(effect);
      const effectAuthor = this.getEffectAuthor(effect);

      // Поиск по названию, описанию и автору
      const matchesQuery =
        effectName.toLowerCase().includes(query) ||
        effectDescription.toLowerCase().includes(query) ||
        effectAuthor.toLowerCase().includes(query);

      if (matchesQuery) {
        effect.style.display = "flex";
        visibleCount++;
      } else {
        effect.style.display = "none";
      }
    });

    // Показываем или скрываем сообщение "ничего не найдено"
    if (visibleCount === 0) {
      this.showNoResults();
    } else {
      this.hideNoResults();
    }

    console.log(`Found ${visibleCount} effects matching "${query}"`);
  }

  showNoResults() {
    if (this.hasNoResultsTarget) {
      this.noResultsTarget.style.display = "flex";
    }
  }

  hideNoResults() {
    if (this.hasNoResultsTarget) {
      this.noResultsTarget.style.display = "none";
    }
  }

  getEffectName(effectElement) {
    const nameElement = effectElement.querySelector(
      ".A_TextEffectCard, .A_Header3"
    );
    return nameElement ? nameElement.textContent.trim() : "";
  }

  getEffectDescription(effectElement) {
    const descElement = effectElement.querySelector(
      ".A_TextEffectDescription, p"
    );
    return descElement ? descElement.textContent.trim() : "";
  }

  getEffectAuthor(effectElement) {
    const authorElement = effectElement.querySelector(
      ".A_TextTag, .A_TextCaption"
    );
    return authorElement ? authorElement.textContent.trim() : "";
  }
}
