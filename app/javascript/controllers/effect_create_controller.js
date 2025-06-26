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
    "categoriesBlock",
    "tagsBlock",
    "linkPreviewBlock",
    "previewArea",
    "effectName",
    "effectDescription",
    "previewText",
    "instructionText",
    "categoryTag",
    "nextButton",
    "backButton",
    "previewCard",
    "previewImageBefore",
    "previewImageAfter",
    "previewName",
    "previewPrograms",
    "progressBar",
  ];

  connect() {
    this.currentStep = 0;
    this.updateButtonVisibility();
    // Инициализируем превью при загрузке
    this.updatePreviewName();
    // Настраиваем слушатели для валидации
    this.setupValidationListeners();
    // Проводим первоначальную валидацию
    this.validateCurrentStep();
    // Добавляем обработчик submit для формы
    this.setupFormSubmitHandler();
    // Устанавливаем начальное состояние прогресс-бара
    this.updateProgressBar(20);
  }

  setupFormSubmitHandler() {
    const form = this.element.querySelector("form");
    if (form) {
      form.addEventListener("submit", (event) => {
        // Проверяем, что форма не отправляется случайно с пустыми данными
        const nameField = form.querySelector('input[name="effect[name]"]');
        const descriptionField = form.querySelector(
          'textarea[name="effect[description]"]'
        );
        const imageBeforeField = form.querySelector(
          'input[name="image_before"]'
        );

        if (
          (!nameField || !nameField.value.trim()) &&
          (!descriptionField || !descriptionField.value.trim()) &&
          (!imageBeforeField || !imageBeforeField.files.length)
        ) {
          console.log("Preventing form submission with empty data");
          event.preventDefault();
          return false;
        }
      });
    }
  }

  open() {
    console.log("=== OPEN METHOD CALLED ===");
    console.log("Element:", this.element);
    console.log("Has dialog target:", this.hasDialogTarget);

    let dialog;
    if (this.hasDialogTarget) {
      console.log("Dialog target:", this.dialogTarget);
      dialog = this.dialogTarget;
    } else {
      // Если target не найден, ищем диалог в элементе
      dialog = this.element.querySelector("dialog");
      console.log("Dialog found via querySelector:", dialog);
    }

    if (dialog) {
      // Показываем модалку с flex и открываем её
      dialog.style.display = "flex";
      dialog.showModal();

      // Добавляем небольшую задержку для плавной анимации
      setTimeout(() => {
        dialog.style.opacity = "1";
        dialog.style.transform = "scale(1) translateY(0)";
      }, 10);

      console.log("Opened dialog with animation");
    } else {
      console.log("No dialog found!");
    }

    document.body.style.overflow = "hidden";
    this.updateButtonVisibility();
    // Обновляем превью при открытии модального окна
    this.updatePreviewName();
    // Валидируем текущий этап
    this.validateCurrentStep();
    console.log("=== OPEN METHOD FINISHED ===");
  }

  close() {
    console.log("=== CLOSE METHOD CALLED ===");
    console.log("Element:", this.element);
    console.log("Has dialog target:", this.hasDialogTarget);

    // Ищем все диалоги в документе
    const allDialogs = document.querySelectorAll("dialog");
    console.log("All dialogs in document:", allDialogs);

    // Ищем открытые диалоги
    const openDialogs = document.querySelectorAll("dialog[open]");
    console.log("Open dialogs:", openDialogs);

    // Находим открытый диалог в текущем элементе
    const openDialog = this.element.querySelector("dialog[open]");
    console.log("Open dialog in this element:", openDialog);

    let dialogToClose = openDialog;
    if (!dialogToClose && this.hasDialogTarget) {
      dialogToClose = this.dialogTarget;
    }

    if (dialogToClose) {
      console.log(
        "Attempting to close dialog with animation:",
        dialogToClose.id
      );

      // Анимация закрытия
      dialogToClose.style.opacity = "0";
      dialogToClose.style.transform = "scale(0.9) translateY(-30px)";

      // Закрываем диалог после анимации
      setTimeout(() => {
        dialogToClose.close();
        dialogToClose.style.display = "none";
        dialogToClose.removeAttribute("open");
        console.log("Dialog closed after animation");
      }, 300);
    } else {
      console.log(
        "No dialog found in this element, trying to close any open dialog"
      );
      // Попробуем закрыть любой открытый диалог
      openDialogs.forEach((dialog) => {
        console.log("Force closing dialog:", dialog.id);
        dialog.style.opacity = "0";
        dialog.style.transform = "scale(0.9) translateY(-30px)";

        setTimeout(() => {
          dialog.close();
          dialog.style.display = "none";
          dialog.removeAttribute("open");
        }, 300);
      });
    }

    // Восстанавливаем правильные стили для body
    document.body.style.overflow = "auto";
    document.body.style.overflowX = "hidden";
    // Сбрасываем форму к первоначальному состоянию
    this.resetForm();
    console.log("=== CLOSE METHOD FINISHED ===");
  }

  resetForm() {
    // Находим форму
    const form = this.element.querySelector("form");
    if (form) {
      // Сбрасываем все поля формы
      form.reset();
    }

    // Сбрасываем превью изображений
    if (this.hasOutputBeforeTarget) {
      // Удаляем обработчики GIF если есть
      if (this.outputBeforeTarget._gifMouseEnter) {
        this.outputBeforeTarget.removeEventListener(
          "mouseenter",
          this.outputBeforeTarget._gifMouseEnter
        );
        this.outputBeforeTarget.removeEventListener(
          "mouseleave",
          this.outputBeforeTarget._gifMouseLeave
        );
      }
      this.outputBeforeTarget.src = "";
      this.outputBeforeTarget.style.display = "none";
      delete this.outputBeforeTarget.dataset.gifUrl;
      delete this.outputBeforeTarget.dataset.staticUrl;
      delete this.outputBeforeTarget.dataset.isGif;
    }
    if (this.hasOutputAfterTarget) {
      // Удаляем обработчики GIF если есть
      if (this.outputAfterTarget._gifMouseEnter) {
        this.outputAfterTarget.removeEventListener(
          "mouseenter",
          this.outputAfterTarget._gifMouseEnter
        );
        this.outputAfterTarget.removeEventListener(
          "mouseleave",
          this.outputAfterTarget._gifMouseLeave
        );
      }
      this.outputAfterTarget.src = "";
      this.outputAfterTarget.style.display = "none";
      delete this.outputAfterTarget.dataset.gifUrl;
      delete this.outputAfterTarget.dataset.staticUrl;
      delete this.outputAfterTarget.dataset.isGif;
    }

    // Сбрасываем превью карточки
    if (this.hasPreviewImageBeforeTarget) {
      this.previewImageBeforeTarget.innerHTML =
        '<img src="/assets/emptyImage.svg" alt="Картинка" class="Q_emptyImage">';
    }
    if (this.hasPreviewImageAfterTarget) {
      this.previewImageAfterTarget.innerHTML =
        '<img src="/assets/emptyImage.svg" alt="Картинка" class="Q_emptyImage">';
    }

    // Сбрасываем активные категории
    const categoryButtons = this.element.querySelectorAll(
      ".A_TextTagFeed[data-category]"
    );
    categoryButtons.forEach((button) => {
      button.classList.remove("active");
    });

    // Сбрасываем чекбоксы и радиокнопки
    const checkboxes = this.element.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach((checkbox) => {
      checkbox.checked = false;
    });

    const radios = this.element.querySelectorAll('input[type="radio"]');
    radios.forEach((radio) => {
      radio.checked = false;
    });

    // Возвращаемся к первому шагу
    this.resetToFirstStep();

    // Обновляем превью
    this.updatePreviewName();
    this.updatePreviewPrograms();

    // Валидируем первый шаг
    this.validateCurrentStep();
  }

  resetToFirstStep() {
    // Сбрасываем текущий шаг
    this.currentStep = 0;

    // Показываем только первый блок
    if (this.hasEffectInfoTarget) this.effectInfoTarget.style.display = "flex";
    if (this.hasInstructionBlockTarget)
      this.instructionBlockTarget.style.display = "none";
    if (this.hasCategoriesBlockTarget)
      this.categoriesBlockTarget.style.display = "none";
    if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "none";
    if (this.hasLinkPreviewBlockTarget)
      this.linkPreviewBlockTarget.style.display = "none";

    // Сбрасываем текст кнопки "Далее"
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.textContent = "Далее";
    }

    // Сбрасываем прогресс-бар
    this.updateProgressBar(20);

    // Обновляем видимость кнопок
    this.updateButtonVisibility();
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
      // Запускаем валидацию после загрузки изображения
      this.validateCurrentStep();
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
    // Обновляем изображение "до"
    if (
      this.hasInputBeforeTarget &&
      this.inputBeforeTarget.files[0] &&
      this.hasPreviewImageBeforeTarget
    ) {
      const file = this.inputBeforeTarget.files[0];
      const reader = new FileReader();
      reader.onload = (e) => {
        const imageUrl = e.target.result;
        const img = document.createElement("img");
        img.alt = "До применения";
        img.className = "A_PhotoEffect";
        img.style.width = "100%";
        img.style.height = "100%";
        img.style.objectFit = "cover";

        // Проверяем, является ли файл GIF
        if (file.type === "image/gif") {
          this.setupPreviewGifImage(img, imageUrl, file);
        } else {
          img.src = imageUrl;
        }

        this.previewImageBeforeTarget.innerHTML = "";
        this.previewImageBeforeTarget.appendChild(img);
      };
      reader.readAsDataURL(file);
    }

    // Обновляем изображение "после"
    if (
      this.hasInputAfterTarget &&
      this.inputAfterTarget.files[0] &&
      this.hasPreviewImageAfterTarget
    ) {
      const file = this.inputAfterTarget.files[0];
      const reader = new FileReader();
      reader.onload = (e) => {
        const imageUrl = e.target.result;
        const img = document.createElement("img");
        img.alt = "После применения";
        img.className = "A_PhotoEffect";
        img.style.width = "100%";
        img.style.height = "100%";
        img.style.objectFit = "cover";

        // Проверяем, является ли файл GIF
        if (file.type === "image/gif") {
          this.setupPreviewGifImage(img, imageUrl, file);
        } else {
          img.src = imageUrl;
        }

        this.previewImageAfterTarget.innerHTML = "";
        this.previewImageAfterTarget.appendChild(img);
      };
      reader.readAsDataURL(file);
    }

    // Обновляем название эффекта
    this.updatePreviewName();

    // Обновляем программы
    this.updatePreviewPrograms();
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

    const currentStep = this.getCurrentStep();

    if (currentStep === 0) {
      if (this.hasEffectInfoTarget)
        this.effectInfoTarget.style.display = "none";
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "flex";
      this.updateProgressBar(40);
    } else if (currentStep === 1) {
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "none";
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "flex";
      this.updateProgressBar(60);
    } else if (currentStep === 2) {
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "none";
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "flex";
      this.updateProgressBar(80);
    } else if (currentStep === 3) {
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "none";
      if (this.hasLinkPreviewBlockTarget)
        this.linkPreviewBlockTarget.style.display = "flex";

      if (this.hasNextButtonTarget) {
        this.nextButtonTarget.textContent = "Отправить на модерацию";
        this.nextButtonTarget.classList.add("submit-button");
      }

      // Обновляем превью карточки при переходе на последний шаг
      this.updatePreviewCard();
      this.updateProgressBar(100);
    } else if (currentStep === 4) {
      this.submitForm();
      return;
    }

    this.currentStep = currentStep + 1;
    this.updateButtonVisibility();
    // Валидируем новый этап
    this.validateCurrentStep();
  }

  previousStep(event) {
    event.preventDefault();

    const currentStep = this.getCurrentStep();

    if (currentStep === 1) {
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "none";
      if (this.hasEffectInfoTarget)
        this.effectInfoTarget.style.display = "flex";
      this.updateProgressBar(20);
    } else if (currentStep === 2) {
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "none";
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "flex";
      this.updateProgressBar(40);
    } else if (currentStep === 3) {
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "none";
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "flex";
      this.updateProgressBar(60);
    } else if (currentStep === 4) {
      if (this.hasLinkPreviewBlockTarget)
        this.linkPreviewBlockTarget.style.display = "none";
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "flex";

      if (this.hasNextButtonTarget) {
        this.nextButtonTarget.textContent = "Далее";
        this.nextButtonTarget.classList.remove("submit-button");
      }
      this.updateProgressBar(80);
    }

    this.currentStep = currentStep - 1;
    this.updateButtonVisibility();
    // Валидируем новый этап
    this.validateCurrentStep();
  }

  updateButtonVisibility() {
    const currentStep = this.getCurrentStep();

    if (this.hasBackButtonTarget) {
      if (currentStep === 0) {
        this.backButtonTarget.style.display = "none";
      } else {
        this.backButtonTarget.style.display = "inline-block";
      }
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
    // Используем внутреннее состояние для отслеживания текущего шага
    return this.currentStep || 0;
  }

  updateProgressBar(percentage) {
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percentage}%`;
    }
  }

  updatePreviewText() {
    const effectName = this.effectNameTarget.value;

    this.previewTextTarget.textContent = effectName || "Название";
  }

  updatePreviewName() {
    if (this.hasPreviewNameTarget && this.hasEffectNameTarget) {
      const effectName = this.effectNameTarget.value;
      this.previewNameTarget.textContent = effectName || "Название эффекта";
    }
  }

  updatePreviewPrograms() {
    if (this.hasPreviewProgramsTarget) {
      const selectedPrograms = [];
      const programCheckboxes = this.element.querySelectorAll(
        'input[type="checkbox"][name*="program_list_"]:checked'
      );

      programCheckboxes.forEach((checkbox) => {
        const programKey = checkbox.value;
        const programLabel = checkbox
          .closest("label")
          .querySelector("span").textContent;
        selectedPrograms.push({ key: programKey, label: programLabel });
      });

      // Очищаем контейнер программ
      this.previewProgramsTarget.innerHTML = "";

      // Добавляем иконки программ
      selectedPrograms.forEach((program) => {
        const programDiv = document.createElement("div");
        programDiv.className = "A_Program";

        // Создаем иконку программы (если есть)
        const iconImg = document.createElement("img");
        iconImg.className = "Q_ProgramIconImage";
        iconImg.alt = program.label;

        // Определяем путь к иконке на основе ключа программы
        const iconPath = this.getProgramIconPath(program.key);
        if (iconPath) {
          iconImg.src = iconPath;
          programDiv.appendChild(iconImg);
        }

        this.previewProgramsTarget.appendChild(programDiv);
      });
    }
  }

  getProgramIconPath(programKey) {
    const iconMap = {
      photoshop: "/assets/photoshop_icon.svg",
      lightroom: "/assets/lightroom_icon.svg",
      after_effects: "/assets/after_effects_icon.svg",
      premiere_pro: "/assets/premiere_icon.svg",
      blender: "/assets/blender_icon.svg",
      affinity_photo: "/assets/affinity_photo_icon.svg",
      capture_one: "/assets/capture_one_icon.svg",
      maya: "/assets/maya_icon.svg",
      cinema_4d: "/assets/cinema_4d_icon.svg",
      "3ds_max": "/assets/3ds_max_icon.svg",
      zbrush: "/assets/zbrush_icon.svg",
      unreal: "/assets/unreal_icon.svg",
      davinci: "/assets/davinci_icon.svg",
      substance: "/assets/substance_icon.svg",
      protopie: "/assets/protopie_icon.svg",
      krita: "/assets/krita_icon.svg",
      sketch: "/assets/sketch_icon.svg",
      animate: "/assets/animate_icon.svg",
      figma: "/assets/figma_icon.svg",
      clip: "/assets/clip_icon.svg",
      nuke: "/assets/nuke_icon.svg",
      fc: "/assets/fc_icon.svg",
      procreate: "/assets/procreate_icon.svg",
      godot: "/assets/godot_icon.svg",
      lens: "/assets/lens_icon.svg",
      rive: "/assets/rive_icon.svg",
      unity: "/assets/unity_icon.svg",
      spark: "/assets/spark_icon.svg",
      spine: "/assets/spine_icon.svg",
      toon: "/assets/toon_icon.svg",
    };

    return iconMap[programKey] || null;
  }

  setupValidationListeners() {
    // Слушатели для первого этапа
    if (this.hasEffectNameTarget) {
      this.effectNameTarget.addEventListener("input", () =>
        this.validateCurrentStep()
      );
    }

    // Поле описания уже имеет обработчик в HTML через data-action
    // const descriptionInput = this.element.querySelector(
    //   'textarea[name="effect[description]"]'
    // );
    // if (descriptionInput) {
    //   descriptionInput.addEventListener("input", () =>
    //     this.validateCurrentStep()
    //   );
    // }

    if (this.hasInputBeforeTarget) {
      this.inputBeforeTarget.addEventListener("change", () =>
        this.validateCurrentStep()
      );
    }

    if (this.hasInputAfterTarget) {
      this.inputAfterTarget.addEventListener("change", () =>
        this.validateCurrentStep()
      );
    }

    // Слушатели для второго этапа
    if (this.hasInstructionTextTarget) {
      this.instructionTextTarget.addEventListener("input", () =>
        this.validateCurrentStep()
      );
    }

    // Слушатели для третьего этапа (категории)
    // Категории используют HTML data-action="change->effect-create#validateCurrentStep"
    // Поэтому не добавляем дополнительные слушатели здесь

    // Слушатели для четвертого этапа (задачи, программы, платформы)
    const taskCheckboxes = this.element.querySelectorAll(
      'input[name*="effect[task_list_"]'
    );
    taskCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.validateCurrentStep());
    });

    const programCheckboxes = this.element.querySelectorAll(
      'input[name*="effect[program_list_"]:checked'
    );
    programCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.validateCurrentStep());
    });

    const platformCheckboxes = this.element.querySelectorAll(
      'input[name*="effect[platform_list_"]:checked'
    );
    platformCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.validateCurrentStep());
    });

    // Слушатель для пятого этапа (ссылка)
    const linkInput = this.element.querySelector(
      'input[name="effect[link_to]"]'
    );
    if (linkInput) {
      linkInput.addEventListener("input", () => this.validateCurrentStep());
    }
  }

  validateCurrentStep() {
    const currentStep = this.getCurrentStep();
    console.log("Current step:", currentStep);
    let isValid = false;

    switch (currentStep) {
      case 0:
        isValid = this.validateStep1();
        break;
      case 1:
        isValid = this.validateStep2();
        break;
      case 2:
        isValid = this.validateStep3();
        break;
      case 3:
        isValid = this.validateStep4();
        break;
      case 4:
        isValid = this.validateStep5();
        break;
    }

    console.log("Overall validation result:", isValid);

    // Обновляем состояние кнопки "Далее"
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = !isValid;
      this.nextButtonTarget.classList.toggle(
        "A_ButtonPrimaryDisabled",
        !isValid
      );
      console.log("Button disabled:", !isValid);
    } else {
      console.log("Next button target not found");
    }
  }

  validateStep1() {
    // Проверяем название
    const name = this.hasEffectNameTarget
      ? this.effectNameTarget.value.trim()
      : "";

    // Проверяем описание
    const description = this.hasEffectDescriptionTarget
      ? this.effectDescriptionTarget.value.trim()
      : "";
    console.log(
      "Description input element:",
      this.hasEffectDescriptionTarget ? this.effectDescriptionTarget : null
    );
    console.log("Description input value:", description);

    // Проверяем изображения
    const hasBeforeImage =
      this.hasInputBeforeTarget && this.inputBeforeTarget.files.length > 0;
    const hasAfterImage =
      this.hasInputAfterTarget && this.inputAfterTarget.files.length > 0;

    // Отладочная информация
    console.log("Validation Step 1:");
    console.log("Name:", name, "Length:", name.length);
    console.log("Description:", description, "Length:", description.length);
    console.log("Has before image:", hasBeforeImage);
    console.log("Has after image:", hasAfterImage);
    console.log("hasInputBeforeTarget:", this.hasInputBeforeTarget);
    console.log("hasInputAfterTarget:", this.hasInputAfterTarget);
    if (this.hasInputBeforeTarget) {
      console.log("Before files count:", this.inputBeforeTarget.files.length);
    }
    if (this.hasInputAfterTarget) {
      console.log("After files count:", this.inputAfterTarget.files.length);
    }

    const isValid =
      name.length > 0 &&
      description.length > 0 &&
      hasBeforeImage &&
      hasAfterImage;

    console.log("Step 1 is valid:", isValid);
    return isValid;
  }

  validateStep2() {
    // Проверяем инструкцию
    const instruction = this.hasInstructionTextTarget
      ? this.instructionTextTarget.value.trim()
      : "";
    return instruction.length > 0;
  }

  validateStep3() {
    // Отладочная информация
    console.log("Validation Step 3:");
    console.log("hasCategoriesBlockTarget:", this.hasCategoriesBlockTarget);

    if (!this.hasCategoriesBlockTarget) {
      console.log("Categories block target not available");
      return false;
    }

    // Проверяем выбранную категорию - ищем только в видимом блоке категорий
    const categoriesBlock = this.categoriesBlockTarget;
    console.log("Categories block element:", categoriesBlock);

    // Отладка: найдем все input элементы в блоке
    const allInputs = categoriesBlock.querySelectorAll("input");
    console.log("All inputs in categories block:", allInputs.length);
    allInputs.forEach((input, index) => {
      console.log(
        `Input ${index}: type=${input.type}, name=${input.name}, value=${input.value}, checked=${input.checked}`
      );
    });

    // Ищем выбранную категорию по разным возможным именам полей
    let selectedCategory = categoriesBlock.querySelector(
      'input[name="effect[category_list]"]:checked'
    );

    if (!selectedCategory) {
      selectedCategory = categoriesBlock.querySelector(
        'input[name="category_list"]:checked'
      );
    }

    console.log("Selected category element:", selectedCategory);
    console.log(
      "Selected category value:",
      selectedCategory ? selectedCategory.value : "none"
    );

    // Ищем все радиокнопки категорий по разным именам
    let allCategories = categoriesBlock.querySelectorAll(
      'input[name="effect[category_list]"]'
    );

    if (allCategories.length === 0) {
      allCategories = categoriesBlock.querySelectorAll(
        'input[name="category_list"]'
      );
    }

    console.log("All category radios found:", allCategories.length);
    allCategories.forEach((radio, index) => {
      console.log(
        `Radio ${index}: value=${radio.value}, checked=${radio.checked}`
      );
    });

    const isValid = selectedCategory !== null;
    console.log("Step 3 is valid:", isValid);
    return isValid;
  }

  validateStep4() {
    // Проверяем выбранные задачи и программы
    // Ищем чекбоксы задач с разными именами
    let selectedTasks = this.element.querySelectorAll(
      'input[name*="effect[task_list_"]:checked'
    );

    if (selectedTasks.length === 0) {
      selectedTasks = this.element.querySelectorAll(
        'input[name*="task_list_"]:checked'
      );
    }

    // Ищем чекбоксы программ с разными именами
    let selectedPrograms = this.element.querySelectorAll(
      'input[name*="effect[program_list_"]:checked'
    );

    if (selectedPrograms.length === 0) {
      selectedPrograms = this.element.querySelectorAll(
        'input[name*="program_list_"]:checked'
      );
    }

    console.log("Selected tasks:", selectedTasks.length);
    console.log("Selected programs:", selectedPrograms.length);

    return selectedTasks.length > 0 && selectedPrograms.length > 0;
  }

  validateStep5() {
    // Проверяем введенную ссылку
    let linkInput = this.element.querySelector('input[name="effect[link_to]"]');

    if (!linkInput) {
      linkInput = this.element.querySelector('input[name="link_to"]');
    }

    const link = linkInput ? linkInput.value.trim() : "";
    console.log("Link value:", link);
    return link.length > 0;
  }

  async previewAndCreate() {
    console.log("=== PREVIEW AND CREATE METHOD CALLED ===");

    // Собираем данные формы
    const formData = this.collectFormData();

    // Проверяем, что есть необходимые данные
    if (!this.validateFormData(formData)) {
      alert(
        "Пожалуйста, заполните все обязательные поля перед созданием превью"
      );
      return;
    }

    try {
      // Создаем FormData для отправки файлов
      const form = this.element.querySelector("form");
      const submitFormData = new FormData(form);

      // Добавляем флаг режима превью
      submitFormData.append("preview_mode", "true");

      // Отправляем данные на сервер для создания эффекта
      const response = await fetch("/effects", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        },
        body: submitFormData,
      });

      if (response.ok) {
        // Если ответ JSON, получаем данные и редиректим
        const contentType = response.headers.get("content-type");
        if (contentType && contentType.includes("application/json")) {
          const result = await response.json();
          window.location.href = `/effects/${result.id}`;
        } else {
          // Если HTML redirect, следуем за ним
          window.location.href = response.url;
        }
      } else {
        console.error("Error creating effect:", response.status);
        alert("Произошла ошибка при создании эффекта. Попробуйте еще раз.");
      }
    } catch (error) {
      console.error("Network error:", error);
      alert(
        "Произошла ошибка сети. Проверьте интернет-соединение и попробуйте еще раз."
      );
    }
  }

  collectFormData() {
    const form = this.element.querySelector("form");
    if (!form) return {};

    const formData = {};

    // Собираем основные поля - ищем по разным именам
    let nameField = form.querySelector('input[name="effect[name]"]');
    if (!nameField) nameField = form.querySelector('input[name="name"]');

    let descriptionField = form.querySelector(
      'textarea[name="effect[description]"]'
    );
    if (!descriptionField)
      descriptionField = form.querySelector('textarea[name="description"]');

    let manualField = form.querySelector('textarea[name="effect[manual]"]');
    if (!manualField)
      manualField = form.querySelector('textarea[name="manual"]');

    let linkField = form.querySelector('input[name="effect[link_to]"]');
    if (!linkField) linkField = form.querySelector('input[name="link_to"]');

    let categoryField = form.querySelector(
      'input[name="effect[category_list]"]:checked'
    );
    if (!categoryField)
      categoryField = form.querySelector('input[name="category_list"]:checked');

    if (nameField) formData.name = nameField.value;
    if (descriptionField) formData.description = descriptionField.value;
    if (manualField) formData.manual = manualField.value;
    if (linkField) formData.link_to = linkField.value;
    if (categoryField) formData.category_list = categoryField.value;

    // Собираем программы
    let programCheckboxes = form.querySelectorAll(
      'input[name*="effect[program_list_"]:checked'
    );
    if (programCheckboxes.length === 0) {
      programCheckboxes = form.querySelectorAll(
        'input[name*="program_list_"]:checked'
      );
    }
    const programs = [];
    programCheckboxes.forEach((checkbox) => {
      programs.push(checkbox.value);
    });
    formData.programs = programs;

    // Собираем задачи
    let taskCheckboxes = form.querySelectorAll(
      'input[name*="effect[task_list_"]:checked'
    );
    if (taskCheckboxes.length === 0) {
      taskCheckboxes = form.querySelectorAll(
        'input[name*="task_list_"]:checked'
      );
    }
    const tasks = [];
    taskCheckboxes.forEach((checkbox) => {
      tasks.push(checkbox.value);
    });
    formData.tasks = tasks;

    // Собираем платформы
    let platformCheckboxes = form.querySelectorAll(
      'input[name*="effect[platform_list_"]:checked'
    );
    if (platformCheckboxes.length === 0) {
      platformCheckboxes = form.querySelectorAll(
        'input[name*="platform_list_"]:checked'
      );
    }
    const platforms = [];
    platformCheckboxes.forEach((checkbox) => {
      platforms.push(checkbox.value);
    });
    formData.platforms = platforms;

    return formData;
  }

  validateFormData(formData) {
    // Проверяем обязательные поля
    return formData.name && formData.description && formData.category_list;
  }

  attachFiles() {
    // Обрабатываем файлы - ищем по разным именам
    let beforeInput = this.element.querySelector(
      'input[name="effect[image_before]"]'
    );
    let afterInput = this.element.querySelector(
      'input[name="effect[image_after]"]'
    );

    if (!beforeInput) {
      beforeInput = this.element.querySelector('input[name="image_before"]');
    }
    if (!afterInput) {
      afterInput = this.element.querySelector('input[name="image_after"]');
    }

    const formData = new FormData(this.element.querySelector("form"));

    if (beforeInput && beforeInput.files[0]) {
      console.log("Attaching before file:", beforeInput.files[0].name);
      formData.append("effect[image_before]", beforeInput.files[0]);
    }

    if (afterInput && afterInput.files[0]) {
      console.log("Attaching after file:", afterInput.files[0].name);
      formData.append("effect[image_after]", afterInput.files[0]);
    }

    // Обрабатываем задачи - ищем с разными именами
    const taskCheckboxes = this.element.querySelectorAll(
      'input[name*="effect[task_list_"]:checked'
    );
    if (taskCheckboxes.length === 0) {
      const altTaskCheckboxes = this.element.querySelectorAll(
        'input[name*="task_list_"]:checked'
      );
      altTaskCheckboxes.forEach((checkbox) => {
        formData.append(`effect[task_list_${checkbox.value}]`, checkbox.value);
      });
    } else {
      taskCheckboxes.forEach((checkbox) => {
        formData.append(checkbox.name, checkbox.value);
      });
    }

    // Обрабатываем программы - ищем с разными именами
    const programCheckboxes = this.element.querySelectorAll(
      'input[name*="effect[program_list_"]:checked'
    );
    if (programCheckboxes.length === 0) {
      const altProgramCheckboxes = this.element.querySelectorAll(
        'input[name*="program_list_"]:checked'
      );
      altProgramCheckboxes.forEach((checkbox) => {
        formData.append(
          `effect[program_list_${checkbox.value}]`,
          checkbox.value
        );
      });
    } else {
      programCheckboxes.forEach((checkbox) => {
        formData.append(checkbox.name, checkbox.value);
      });
    }

    // Обрабатываем платформы - ищем с разными именами
    const platformCheckboxes = this.element.querySelectorAll(
      'input[name*="effect[platform_list_"]:checked'
    );
    if (platformCheckboxes.length === 0) {
      const altPlatformCheckboxes = this.element.querySelectorAll(
        'input[name*="platform_list_"]:checked'
      );
      altPlatformCheckboxes.forEach((checkbox) => {
        formData.append(
          `effect[platform_list_${checkbox.value}]`,
          checkbox.value
        );
      });
    } else {
      platformCheckboxes.forEach((checkbox) => {
        formData.append(checkbox.name, checkbox.value);
      });
    }

    return formData;
  }
}
