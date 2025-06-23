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
      const file = input.files[0];
      const reader = new FileReader();

      reader.onload = (e) => {
        const imageUrl = e.target.result;

        // Проверяем, является ли файл GIF
        if (file.type === "image/gif") {
          this.setupGifImage(output, imageUrl, file);
        } else {
          // Обычное изображение
          output.src = imageUrl;
          output.style.width = "100%";
          output.style.height = "100%";
          output.style.objectFit = "cover";
        }
      };
      reader.readAsDataURL(file);

      this.updatePreviewCard();
    }
  }

  setupGifImage(output, imageUrl, file) {
    // Создаем canvas для статичного превью
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    const img = new Image();

    img.onload = () => {
      canvas.width = img.width;
      canvas.height = img.height;
      ctx.drawImage(img, 0, 0);

      // Получаем статичную версию (первый кадр)
      const staticImageUrl = canvas.toDataURL();

      // Настраиваем изображение
      output.src = staticImageUrl;
      output.style.width = "100%";
      output.style.height = "100%";
      output.style.objectFit = "cover";
      output.style.cursor = "pointer";

      // Сохраняем оригинальный GIF URL для анимации
      output.dataset.gifUrl = imageUrl;
      output.dataset.staticUrl = staticImageUrl;
      output.dataset.isGif = "true";

      // Добавляем обработчики наведения
      this.addGifHoverHandlers(output);
    };

    img.src = imageUrl;
  }

  addGifHoverHandlers(imageElement) {
    // Удаляем старые обработчики если есть
    imageElement.removeEventListener("mouseenter", imageElement._gifMouseEnter);
    imageElement.removeEventListener("mouseleave", imageElement._gifMouseLeave);

    // Создаем новые обработчики
    imageElement._gifMouseEnter = () => {
      if (imageElement.dataset.isGif === "true") {
        imageElement.src = imageElement.dataset.gifUrl;
      }
    };

    imageElement._gifMouseLeave = () => {
      if (imageElement.dataset.isGif === "true") {
        imageElement.src = imageElement.dataset.staticUrl;
      }
    };

    // Добавляем обработчики
    imageElement.addEventListener("mouseenter", imageElement._gifMouseEnter);
    imageElement.addEventListener("mouseleave", imageElement._gifMouseLeave);
  }

  updatePreviewCard() {
    const previewImages = document.querySelectorAll(".Q_emptyImage");

    if (this.hasInputBeforeTarget && this.inputBeforeTarget.files[0]) {
      const file = this.inputBeforeTarget.files[0];
      const reader = new FileReader();
      reader.onload = (e) => {
        if (previewImages[0]) {
          const imageUrl = e.target.result;

          // Проверяем, является ли файл GIF
          if (file.type === "image/gif") {
            this.setupPreviewGifImage(previewImages[0], imageUrl, file);
          } else {
            previewImages[0].src = imageUrl;
            previewImages[0].style.width = "100%";
            previewImages[0].style.height = "100%";
            previewImages[0].style.objectFit = "cover";
          }
        }
      };
      reader.readAsDataURL(file);
    }

    if (this.hasInputAfterTarget && this.inputAfterTarget.files[0]) {
      const file = this.inputAfterTarget.files[0];
      const reader = new FileReader();
      reader.onload = (e) => {
        if (previewImages[1]) {
          const imageUrl = e.target.result;

          // Проверяем, является ли файл GIF
          if (file.type === "image/gif") {
            this.setupPreviewGifImage(previewImages[1], imageUrl, file);
          } else {
            previewImages[1].src = imageUrl;
            previewImages[1].style.width = "100%";
            previewImages[1].style.height = "100%";
            previewImages[1].style.objectFit = "cover";
          }
        }
      };
      reader.readAsDataURL(file);
    }
  }

  setupPreviewGifImage(imgElement, imageUrl, file) {
    // Создаем canvas для статичного превью
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    const tempImg = new Image();

    tempImg.onload = () => {
      canvas.width = tempImg.width;
      canvas.height = tempImg.height;
      ctx.drawImage(tempImg, 0, 0);

      // Получаем статичную версию (первый кадр)
      const staticImageUrl = canvas.toDataURL();

      // Настраиваем изображение
      imgElement.src = staticImageUrl;
      imgElement.style.width = "100%";
      imgElement.style.height = "100%";
      imgElement.style.objectFit = "cover";
      imgElement.style.cursor = "pointer";

      // Сохраняем оригинальный GIF URL для анимации
      imgElement.dataset.gifUrl = imageUrl;
      imgElement.dataset.staticUrl = staticImageUrl;
      imgElement.dataset.isGif = "true";

      // Добавляем обработчики наведения
      this.addGifHoverHandlers(imgElement);
    };

    tempImg.src = imageUrl;
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
        this.instructionBlockTarget.style.display = "flex";

      navItems[0].classList.remove("A_TextTagFeedActive");
      navItems[1].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 1) {
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "none";
      if (this.hasPreviewAreaTarget)
        this.previewAreaTarget.style.display = "none";
      if (this.hasTagsLinkBlockTarget)
        this.tagsLinkBlockTarget.style.display = "flex";

      navItems[1].classList.remove("A_TextTagFeedActive");
      navItems[2].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 2) {
      if (this.hasTagsLinkBlockTarget)
        this.tagsLinkBlockTarget.style.display = "none";
      if (this.hasModerationBlockTarget)
        this.moderationBlockTarget.style.display = "flex";

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
