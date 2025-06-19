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
  ];

  connect() {
    this.updateButtonVisibility();
    // Инициализируем превью при загрузке
    this.updatePreviewName();
    // Настраиваем слушатели для валидации
    this.setupValidationListeners();
    // Проводим первоначальную валидацию
    this.validateCurrentStep();
    // Добавляем обработчик submit для формы
    this.setupFormSubmitHandler();
  }

  setupFormSubmitHandler() {
    const form = this.element.querySelector("form");
    if (form) {
      form.addEventListener("submit", (event) => {
        // Проверяем, что форма не отправляется случайно с пустыми данными
        const nameField = form.querySelector('input[name="name"]');
        const descriptionField = form.querySelector(
          'textarea[name="description"]'
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

    if (this.hasDialogTarget) {
      console.log("Dialog target:", this.dialogTarget);
      // Убеждаемся, что диалог видим перед открытием
      this.dialogTarget.style.display = "";
      this.dialogTarget.showModal();
      console.log("Opened dialog via target");
    } else {
      // Если target не найден, ищем диалог в элементе
      const dialog = this.element.querySelector("dialog");
      console.log("Dialog found via querySelector:", dialog);
      if (dialog) {
        // Убеждаемся, что диалог видим перед открытием
        dialog.style.display = "";
        dialog.showModal();
        console.log("Opened dialog via querySelector");
      } else {
        console.log("No dialog found!");
      }
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

    if (openDialog) {
      console.log("Attempting to close dialog:", openDialog.id);
      openDialog.close();
      // Принудительно скрываем диалог через CSS если close() не сработал
      openDialog.style.display = "none";
      openDialog.removeAttribute("open");
      console.log("Dialog closed and hidden via querySelector");
    } else if (this.hasDialogTarget) {
      console.log("Attempting to close dialog via target");
      this.dialogTarget.close();
      // Принудительно скрываем диалог через CSS если close() не сработал
      this.dialogTarget.style.display = "none";
      this.dialogTarget.removeAttribute("open");
      console.log("Dialog closed and hidden via target");
    } else {
      console.log(
        "No dialog found in this element, trying to close any open dialog"
      );
      // Попробуем закрыть любой открытый диалог
      openDialogs.forEach((dialog) => {
        console.log("Force closing dialog:", dialog.id);
        dialog.close();
        dialog.style.display = "none";
        dialog.removeAttribute("open");
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
      this.outputBeforeTarget.src = "";
      this.outputBeforeTarget.style.display = "none";
    }
    if (this.hasOutputAfterTarget) {
      this.outputAfterTarget.src = "";
      this.outputAfterTarget.style.display = "none";
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
    // Сбрасываем навигацию к первому шагу
    const navItems = this.element.querySelectorAll(
      ".M_SettingsNavigationEffect .A_TextTagFeed"
    );

    navItems.forEach((item, index) => {
      if (index === 0) {
        item.classList.add("A_TextTagFeedActive");
      } else {
        item.classList.remove("A_TextTagFeedActive");
      }
    });

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
      const reader = new FileReader();
      reader.onload = (e) => {
        output.src = e.target.result;
        output.style.width = "100%";
        output.style.height = "100%";
        output.style.objectFit = "cover";
      };
      reader.readAsDataURL(input.files[0]);

      this.updatePreviewCard();
      // Запускаем валидацию после загрузки изображения
      this.validateCurrentStep();
    }
  }

  updatePreviewCard() {
    // Обновляем изображение "до"
    if (
      this.hasInputBeforeTarget &&
      this.inputBeforeTarget.files[0] &&
      this.hasPreviewImageBeforeTarget
    ) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const img = document.createElement("img");
        img.src = e.target.result;
        img.alt = "До применения";
        img.className = "A_PhotoEffect";
        img.style.width = "100%";
        img.style.height = "100%";
        img.style.objectFit = "cover";

        this.previewImageBeforeTarget.innerHTML = "";
        this.previewImageBeforeTarget.appendChild(img);
      };
      reader.readAsDataURL(this.inputBeforeTarget.files[0]);
    }

    // Обновляем изображение "после"
    if (
      this.hasInputAfterTarget &&
      this.inputAfterTarget.files[0] &&
      this.hasPreviewImageAfterTarget
    ) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const img = document.createElement("img");
        img.src = e.target.result;
        img.alt = "После применения";
        img.className = "A_PhotoEffect";
        img.style.width = "100%";
        img.style.height = "100%";
        img.style.objectFit = "cover";

        this.previewImageAfterTarget.innerHTML = "";
        this.previewImageAfterTarget.appendChild(img);
      };
      reader.readAsDataURL(this.inputAfterTarget.files[0]);
    }

    // Обновляем название эффекта
    this.updatePreviewName();

    // Обновляем программы
    this.updatePreviewPrograms();
  }

  nextStep(event) {
    event.preventDefault();

    const navItems = this.element.querySelectorAll(
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
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "flex";

      navItems[1].classList.remove("A_TextTagFeedActive");
      navItems[2].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 2) {
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "none";
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "flex";

      navItems[2].classList.remove("A_TextTagFeedActive");
      navItems[3].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 3) {
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "none";
      if (this.hasLinkPreviewBlockTarget)
        this.linkPreviewBlockTarget.style.display = "flex";

      if (this.hasNextButtonTarget) {
        this.nextButtonTarget.textContent = "Отправить на модерацию";
      }

      // Обновляем превью карточки при переходе на последний шаг
      this.updatePreviewCard();

      navItems[3].classList.remove("A_TextTagFeedActive");
      navItems[4].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 4) {
      this.submitForm();
      return;
    }

    this.updateButtonVisibility();
    // Валидируем новый этап
    this.validateCurrentStep();
  }

  previousStep(event) {
    event.preventDefault();

    const navItems = this.element.querySelectorAll(
      ".M_SettingsNavigationEffect .A_TextTagFeed"
    );
    let currentStep = 0;

    navItems.forEach((item, index) => {
      if (item.classList.contains("A_TextTagFeedActive")) {
        currentStep = index;
      }
    });

    if (currentStep === 1) {
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "none";
      if (this.hasEffectInfoTarget)
        this.effectInfoTarget.style.display = "flex";

      navItems[1].classList.remove("A_TextTagFeedActive");
      navItems[0].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 2) {
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "none";
      if (this.hasInstructionBlockTarget)
        this.instructionBlockTarget.style.display = "flex";

      navItems[2].classList.remove("A_TextTagFeedActive");
      navItems[1].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 3) {
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "none";
      if (this.hasCategoriesBlockTarget)
        this.categoriesBlockTarget.style.display = "flex";

      navItems[3].classList.remove("A_TextTagFeedActive");
      navItems[2].classList.add("A_TextTagFeedActive");
    } else if (currentStep === 4) {
      if (this.hasLinkPreviewBlockTarget)
        this.linkPreviewBlockTarget.style.display = "none";
      if (this.hasTagsBlockTarget) this.tagsBlockTarget.style.display = "flex";

      if (this.hasNextButtonTarget) {
        this.nextButtonTarget.textContent = "Далее";
      }

      navItems[4].classList.remove("A_TextTagFeedActive");
      navItems[3].classList.add("A_TextTagFeedActive");
    }

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
    const activeItem = this.element.querySelector(
      ".M_SettingsNavigationEffect .A_TextTagFeedActive"
    );
    return Array.from(activeItem.parentElement.children).indexOf(activeItem);
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
      illustrator: "/assets/illustrator_icon.svg",
      premiere_pro: "/assets/premiere_pro_icon.svg",
      blender: "/assets/blender_icon.svg",
      affinity_photo: "/assets/affinity_photo_icon.svg",
      capture_one: "/assets/capture_one_icon.svg",
      maya: "/assets/maya_icon.svg",
      cinema_4d: "/assets/cinema_4d_icon.svg",
      "3ds_max": "/assets/3ds_max_icon.svg",
      zbrush: "/assets/zbrush_icon.svg",
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
      'input[name*="task_list_"]'
    );
    taskCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.validateCurrentStep());
    });

    const programCheckboxes = this.element.querySelectorAll(
      'input[name*="program_list_"]'
    );
    programCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", () => this.validateCurrentStep());
    });

    const platformCheckboxes = this.element.querySelectorAll(
      'input[name*="platform_list_"]'
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

    const selectedCategory = categoriesBlock.querySelector(
      'input[name="category_list"]:checked'
    );

    console.log("Selected category element:", selectedCategory);
    console.log(
      "Selected category value:",
      selectedCategory ? selectedCategory.value : "none"
    );

    const allCategories = categoriesBlock.querySelectorAll(
      'input[name="category_list"]'
    );
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
    // Проверяем выбранные задачи (минимум 1)
    const selectedTasks = this.element.querySelectorAll(
      'input[name*="task_list_"]:checked'
    );

    // Проверяем выбранные программы (минимум 1)
    const selectedPrograms = this.element.querySelectorAll(
      'input[name*="program_list_"]:checked'
    );

    // Проверяем выбранные платформы (минимум 1)
    const selectedPlatforms = this.element.querySelectorAll(
      'input[name*="platform_list_"]:checked'
    );

    return (
      selectedTasks.length > 0 &&
      selectedPrograms.length > 0 &&
      selectedPlatforms.length > 0
    );
  }

  validateStep5() {
    // Отладочная информация
    console.log("Validation Step 5:");

    // Найдем блок ссылки и посмотрим все input элементы
    const linkPreviewBlock = this.linkPreviewBlockTarget;
    console.log("Link preview block element:", linkPreviewBlock);

    if (linkPreviewBlock) {
      const allInputs = linkPreviewBlock.querySelectorAll("input");
      console.log("All inputs in link preview block:", allInputs.length);
      allInputs.forEach((input, index) => {
        console.log(
          `Input ${index}: type=${input.type}, name=${input.name}, value=${input.value}`
        );
      });
    }

    // Проверяем ссылку на скачивание
    const linkInput = linkPreviewBlock.querySelector('input[name="link_to"]');
    console.log("Link input element:", linkInput);

    const link = linkInput ? linkInput.value.trim() : "";
    console.log("Link value:", link, "Length:", link.length);

    // Простая валидация URL - проверяем только длину больше 2 символов
    const isValid = link.length > 2;

    console.log("Link length validation:", isValid);
    console.log("Step 5 is valid:", isValid);

    return isValid;
  }
}
