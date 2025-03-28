import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"];

  connect() {
    console.log("CollectionModal controller connected");
  }

  open() {
    console.log("Opening modal");
    this.modalTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
    this.modalTarget.style.display = "flex";
    this.modalTarget.style.justifyContent = "center";
    this.modalTarget.style.alignItems = "center";
    this.modalTarget.style.zIndex = "9999";
  }

  close() {
    this.modalTarget.classList.add("hidden");
    this.modalTarget.style.display = "none";
    document.body.style.overflow = "auto";
  }
}
