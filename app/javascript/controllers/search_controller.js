import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["icon", "input"];

  toggleSearch(event) {
    event.preventDefault();
    this.iconTarget.classList.toggle("hidden");
    this.inputTarget.classList.toggle("hidden");
    this.element.classList.toggle("A_searchWrapperOpen");

    if (!this.inputTarget.classList.contains("hidden")) {
      this.inputTarget.focus();
    }
  }

  // Hide search and show icon when clicking outside or pressing ESC
  closeSearch(event) {
    if (event.type === "keyup" && event.key !== "Escape") return;

    if (!this.element.contains(event.target) || event.key === "Escape") {
      this.iconTarget.classList.remove("hidden");
      this.inputTarget.classList.add("hidden");
      this.element.classList.remove("A_searchWrapperOpen");
    }
  }

  connect() {
    document.addEventListener("click", this.closeSearch.bind(this));
    document.addEventListener("keyup", this.closeSearch.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.closeSearch.bind(this));
    document.removeEventListener("keyup", this.closeSearch.bind(this));
  }
}
