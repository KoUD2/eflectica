import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay", "input", "results"];

  connect() {
    console.log("Mobile search controller connected");
    this.debounceTimer = null;

    // Add document click listener to close search when clicking outside
    this.handleOutsideClick = this.handleOutsideClick.bind(this);
    document.addEventListener("click", this.handleOutsideClick);
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick);
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }
  }

  openSearch(event) {
    event.preventDefault();
    event.stopPropagation();
    console.log("Opening mobile search");

    // Close burger menu if it's open
    const burgerMenu = document.querySelector(".O_MobileMenu");
    if (burgerMenu && burgerMenu.classList.contains("O_MobileMenuOpen")) {
      const burgerElement = document.querySelector(
        '[data-controller*="burger-menu"]'
      );
      if (burgerElement) {
        const burgerController =
          this.application.getControllerForElementAndIdentifier(
            burgerElement,
            "burger-menu"
          );
        if (burgerController) {
          burgerController.closeMenu();
        }
      }
    }

    if (this.overlayTarget) {
      this.overlayTarget.classList.add("O_MobileSearchOpen");

      // Focus on input after a short delay to ensure it's visible
      setTimeout(() => {
        if (this.inputTarget) {
          this.inputTarget.focus();
        }
      }, 100);
    }
  }

  closeSearch(event) {
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    console.log("Closing mobile search");

    this.overlayTarget.classList.remove("O_MobileSearchOpen");

    // Clear search input and results
    if (this.inputTarget) {
      this.inputTarget.value = "";
    }
    if (this.resultsTarget) {
      this.resultsTarget.innerHTML = "";
    }
  }

  search(event) {
    const query = event.target.value.trim();

    // Clear previous timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    // Debounce search requests
    this.debounceTimer = setTimeout(() => {
      if (query.length >= 2) {
        this.performSearch(query);
      } else {
        this.clearResults();
      }
    }, 300);
  }

  async performSearch(query) {
    try {
      console.log("Performing search for:", query);

      // Show loading state
      if (this.resultsTarget) {
        this.resultsTarget.innerHTML =
          '<div class="A_TextEffectDescription">Поиск...</div>';
      }

      // Make AJAX request to search endpoint
      const response = await fetch(
        `/search?search=${encodeURIComponent(query)}`,
        {
          headers: {
            Accept: "text/html",
            "X-Requested-With": "XMLHttpRequest",
          },
        }
      );

      if (response.ok) {
        const html = await response.text();
        this.displayResults(html);
      } else {
        throw new Error("Search request failed");
      }
    } catch (error) {
      console.error("Search error:", error);
      if (this.resultsTarget) {
        this.resultsTarget.innerHTML =
          '<div class="A_TextEffectDescription">Ошибка поиска</div>';
      }
    }
  }

  displayResults(html) {
    if (!this.resultsTarget) return;

    this.resultsTarget.innerHTML = html;

    // Add click handlers to search result links
    this.addResultLinkHandlers();
  }

  clearResults() {
    if (this.resultsTarget) {
      this.resultsTarget.innerHTML = "";
    }
  }

  stopPropagation(event) {
    console.log("Stopping event propagation for search input");
    event.stopPropagation();
  }

  handleEscape(event) {
    if (
      event.key === "Escape" &&
      this.overlayTarget.classList.contains("O_MobileSearchOpen")
    ) {
      this.closeSearch();
    }
  }

  // Handle outside clicks
  handleOutsideClick(event) {
    if (
      this.overlayTarget.classList.contains("O_MobileSearchOpen") &&
      !this.overlayTarget.contains(event.target)
    ) {
      this.closeSearch();
    }
  }

  addResultLinkHandlers() {
    const links = this.resultsTarget.querySelectorAll("a");

    links.forEach((link) => {
      link.addEventListener("click", (event) => {
        // Close search menu when clicking on result
        setTimeout(() => {
          this.closeSearch();
        }, 100);
      });
    });
  }
}
