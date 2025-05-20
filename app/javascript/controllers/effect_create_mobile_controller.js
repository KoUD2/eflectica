import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "dialog",
    "inputBefore",
    "outputBefore",
    "inputAfter",
    "outputAfter",
    "effectInfo",
    "instructionBlock",
    "moderationBlock",
    "tagsLinkBlock",
    "previewArea",
    "effectName",
    "previewText",
    "instructionText",
    "categoryTag",
    "nextButton",
  ];

  open() {
    this.dialogTarget.showModal();
    document.body.style.overflow = "hidden";
  }

  close() {
    this.dialogTarget.close();
    document.body.classList.remove("overflow-hidden");
  }

  toggleCategory(event) {
    const categoryButton = event.currentTarget;
    categoryButton.classList.toggle("active");
  }

  previewImage(event) {
    const input = event.target;
    let output;

    if (input === this.inputBeforeTarget) {
      output = this.outputBeforeTarget;
    } else if (input === this.inputAfterTarget) {
      output = this.outputAfterTarget;
    }

    if (input.files && input.files[0] && output) {
      const reader = new FileReader();
      reader.onload = (e) => {
        output.src = e.target.result;
        output.style.width = "100%";
        output.style.height = "100%";
        output.style.objectFit = "cover";
      };
      reader.readAsDataURL(input.files[0]);

      this.updatePreviewCard();
    }
  }

  updatePreviewCard() {
    const previewImages = document.querySelectorAll(".Q_emptyImage");

    if (this.hasInputBeforeTarget && this.inputBeforeTarget.files[0]) {
      const reader = new FileReader();
      reader.onload = (e) => {
        if (previewImages[0]) {
          previewImages[0].src = e.target.result;
          previewImages[0].style.width = "100%";
          previewImages[0].style.height = "100%";
          previewImages[0].style.objectFit = "cover";
        }
      };
      reader.readAsDataURL(this.inputBeforeTarget.files[0]);
    }

    if (this.hasInputAfterTarget && this.inputAfterTarget.files[0]) {
      const reader = new FileReader();
      reader.onload = (e) => {
        if (previewImages[1]) {
          previewImages[1].src = e.target.result;
          previewImages[1].style.width = "100%";
          previewImages[1].style.height = "100%";
          previewImages[1].style.objectFit = "cover";
        }
      };
      reader.readAsDataURL(this.inputAfterTarget.files[0]);
    }
  }

  nextStep(event) {
    event.preventDefault();

    const navItems = document.querySelectorAll(
      ".M_SettingsNavigationEffect .A_TextTagFeed"
    );
    let currentStep = 0;

    navItems.forEach((item, index) => {
      if (item.classList.contains("A_TextTagFeedActive")) {
        currentStep = index;
      }
    });

    if (currentStep === 0) {
      if (this.hasEffectInfoTarget)
        this.effectInfoTarget.style.display = "none";
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "block";

      navItems[0].classList.remove("A_TextTagFeedActive");
      navItems[1].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 1) {
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "none";
      if (this.hasPreviewAreaTarget)
        this.previewAreaTarget.style.display = "none";
      if (this.hasTagsLinkBlockTarget)
        this.tagsLinkBlockTarget.style.display = "block";

      navItems[1].classList.remove("A_TextTagFeedActive");
      navItems[2].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 2) {
      if (this.hasTagsLinkBlockTarget)
        this.tagsLinkBlockTarget.style.display = "none";
      if (this.hasModerationBlockTarget)
        this.moderationBlockTarget.style.display = "block";

      if (this.hasNextButtonTarget) {
        this.nextButtonTarget.textContent = "Посмотреть превью";
      }

      navItems[2].classList.remove("A_TextTagFeedActive");
      navItems[3].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 3) {
      this.submitForm();
      return;
    }
  }

  submitForm() {
    const form = this.element.querySelector("form");
    const submitButton = form.querySelector("[data-final-submit]");
    if (submitButton) {
      submitButton.click();
    }
  }

  getCurrentStep() {
    const activeItem = document.querySelector(
      ".M_SettingsNavigationEffect .A_TextTagFeedActive"
    );
    return Array.from(activeItem.parentElement.children).indexOf(activeItem);
  }

  updatePreviewText() {
    const effectName = this.effectNameTarget.value;

    this.previewTextTarget.textContent = effectName || "Название";
  }
}
