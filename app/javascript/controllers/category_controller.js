import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["effectsItem", "viewAllButton"]

  toggle(event) {
    const category = event.currentTarget.dataset.category;
    const effectsList = this.effectsItemTargets.find(
      el => el.dataset.categoryName === category
    );
    const viewAllBtn = this.viewAllButtonTargets.find(
      btn => btn.dataset.category === category
    );

    if (!effectsList || !viewAllBtn) {
      console.error(`Elements not found for category: ${category}`);
      return;
    }

    effectsList.classList.toggle("hidden");
    viewAllBtn.classList.toggle("hidden", effectsList.classList.contains("hidden"));
    this.toggleArrowIcon(event.currentTarget);
  }

  toggleArrowIcon(button) {
    const arrow = button.querySelector('.Q_IconArrowBlack');
    arrow.classList.toggle('rotated');
  }
}
