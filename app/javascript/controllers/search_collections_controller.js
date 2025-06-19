import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "subscriptionsSection", "subscriptionsContainer"];

  connect() {
    this.originalSubscriptions = Array.from(
      this.subscriptionsContainerTarget.children
    );
  }

  search() {
    const query = this.inputTarget.value.toLowerCase().trim();

    if (query === "") {
      this.showOriginalState();
    } else {
      this.performSearch(query);
    }
  }

  showOriginalState() {
    // Показываем все мои коллекции
    this.subscriptionsContainerTarget.innerHTML = "";
    this.originalSubscriptions.forEach((collection) => {
      this.subscriptionsContainerTarget.appendChild(collection.cloneNode(true));
    });
  }

  performSearch(query) {
    // Выполняем только локальный поиск по моим коллекциям
    this.displaySearchResults(null, query);
  }

  displaySearchResults(data, query) {
    // Фильтруем мои коллекции по поисковому запросу
    const filteredSubscriptions = this.originalSubscriptions.filter(
      (collection) => {
        // Ищем в ссылке на коллекцию
        const link = collection.querySelector("a[data-name]");
        if (link) {
          const name = link.dataset.name?.toLowerCase() || "";
          const description = link.dataset.description?.toLowerCase() || "";
          return name.includes(query) || description.includes(query);
        }

        // Альтернативный поиск по data-атрибутам самого элемента
        const name = collection.dataset.name?.toLowerCase() || "";
        const description = collection.dataset.description?.toLowerCase() || "";
        return name.includes(query) || description.includes(query);
      }
    );

    // Обновляем мои коллекции
    this.subscriptionsContainerTarget.innerHTML = "";
    if (filteredSubscriptions.length > 0) {
      filteredSubscriptions.forEach((collection) => {
        this.subscriptionsContainerTarget.appendChild(
          collection.cloneNode(true)
        );
      });
    } else {
      this.subscriptionsContainerTarget.innerHTML =
        "<p>Нет моих коллекций, соответствующих поисковому запросу.</p>";
    }
  }
}
