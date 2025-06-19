import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchInput", "effectsContainer"];

  connect() {
    console.log("Profile effects search controller connected");
    // Сохраняем оригинальные карточки эффектов
    this.originalEffects = Array.from(this.effectsContainerTarget.children);
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
    // Очищаем контейнер и показываем все оригинальные эффекты
    this.effectsContainerTarget.innerHTML = "";
    this.originalEffects.forEach((effect) => {
      this.effectsContainerTarget.appendChild(effect);
    });
  }

  filterEffects(query) {
    // Очищаем контейнер
    this.effectsContainerTarget.innerHTML = "";

    // Фильтруем эффекты по названию, описанию, программам и категориям
    const filteredEffects = this.originalEffects.filter((effectElement) => {
      const effectName = this.getEffectName(effectElement);
      const effectDescription = this.getEffectDescription(effectElement);
      const effectPrograms = this.getEffectPrograms(effectElement);
      const effectCategories = this.getEffectCategories(effectElement);

      return (
        effectName.toLowerCase().includes(query) ||
        effectDescription.toLowerCase().includes(query) ||
        effectPrograms.toLowerCase().includes(query) ||
        effectCategories.toLowerCase().includes(query)
      );
    });

    // Показываем отфильтрованные эффекты
    if (filteredEffects.length > 0) {
      filteredEffects.forEach((effect) => {
        this.effectsContainerTarget.appendChild(effect);
      });
    } else {
      // Показываем сообщение об отсутствии результатов
      this.showNoResults();
    }
  }

  getEffectName(effectElement) {
    // Ищем название эффекта в карточке
    const nameElement = effectElement.querySelector(".A_TextEffectCard");
    return nameElement ? nameElement.textContent.trim() : "";
  }

  getEffectDescription(effectElement) {
    // Получаем описание из data-атрибута, так как оно не отображается в карточке
    const linkElement = effectElement.querySelector("a[data-description]");
    return linkElement ? linkElement.dataset.description || "" : "";
  }

  getEffectPrograms(effectElement) {
    // Получаем программы из data-атрибута
    const linkElement = effectElement.querySelector("a[data-programs]");
    return linkElement ? linkElement.dataset.programs || "" : "";
  }

  getEffectCategories(effectElement) {
    // Получаем категории из data-атрибута
    const linkElement = effectElement.querySelector("a[data-categories]");
    return linkElement ? linkElement.dataset.categories || "" : "";
  }

  showNoResults() {
    const noResultsMessage = document.createElement("div");
    noResultsMessage.className = "A_TextTag A_TextTagBig";
    noResultsMessage.style.textAlign = "center";
    noResultsMessage.style.width = "100%";
    noResultsMessage.style.padding = "2rem";
    noResultsMessage.textContent = "Эффекты не найдены";

    this.effectsContainerTarget.appendChild(noResultsMessage);
  }
}
