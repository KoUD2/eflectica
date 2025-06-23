import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "burger"];

  connect() {
    console.log("Burger menu controller connected");
    console.log("Targets found:", {
      menu: this.hasMenuTarget,
      burger: this.hasBurgerTarget,
    });
    this.addEventListeners();
  }

  disconnect() {
    this.removeEventListeners();
  }

  addEventListeners() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this);
    this.handleEscape = this.handleEscape.bind(this);
    this.handleResize = this.handleResize.bind(this);

    document.addEventListener("click", this.handleOutsideClick);
    document.addEventListener("keyup", this.handleEscape);
    window.addEventListener("resize", this.handleResize);
  }

  removeEventListeners() {
    document.removeEventListener("click", this.handleOutsideClick);
    document.removeEventListener("keyup", this.handleEscape);
    window.removeEventListener("resize", this.handleResize);
  }

  toggle(event) {
    event.preventDefault();
    event.stopPropagation();
    console.log("Burger menu toggle clicked");

    if (this.menuTarget.classList.contains("O_MobileMenuVisible")) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  }

  openMenu() {
    console.log("Opening menu");
    this.menuTarget.classList.add("O_MobileMenuVisible");
    this.setupLinkHandlers();
  }

  closeMenu() {
    console.log("Closing menu");
    this.menuTarget.classList.remove("O_MobileMenuVisible");
  }

  handleOutsideClick(event) {
    if (
      !this.element.contains(event.target) &&
      this.menuTarget.classList.contains("O_MobileMenuVisible")
    ) {
      console.log("Outside click detected, closing menu");
      this.closeMenu();
    }
  }

  handleEscape(event) {
    if (
      event.key === "Escape" &&
      this.menuTarget.classList.contains("O_MobileMenuVisible")
    ) {
      console.log("Escape pressed, closing menu");
      this.closeMenu();
    }
  }

  handleResize() {
    if (
      window.innerWidth > 767 &&
      this.menuTarget.classList.contains("O_MobileMenuVisible")
    ) {
      console.log("Window resized to desktop, closing menu");
      this.closeMenu();
    }
  }

  setupLinkHandlers() {
    const links = this.menuTarget.querySelectorAll("a");

    links.forEach((link) => {
      // Remove any existing listeners
      const newLink = link.cloneNode(true);
      link.parentNode.replaceChild(newLink, link);

      // Add new listener
      newLink.addEventListener("click", (event) => {
        event.preventDefault();
        event.stopPropagation();

        const href = newLink.getAttribute("href");
        console.log("Link clicked:", href);

        // Close menu first
        this.closeMenu();

        // Navigate after a short delay
        setTimeout(() => {
          if (href.startsWith("http")) {
            window.location.href = href;
          } else {
            // Use Turbo if available, otherwise fallback to window.location
            if (typeof Turbo !== "undefined") {
              Turbo.visit(href);
            } else {
              window.location.href = href;
            }
          }
        }, 50);
      });
    });
  }
}
