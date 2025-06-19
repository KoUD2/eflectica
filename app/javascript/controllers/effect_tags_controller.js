import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "taskDropdown",
    "taskToggleButton",
    "selectedTasks",
    "selectedTasksList",
    "programDropdown",
    "programToggleButton",
    "selectedPrograms",
    "selectedProgramsList",
    "platformDropdown",
    "platformToggleButton",
    "selectedPlatforms",
    "selectedPlatformsList",
  ];

  // Словарь для перевода значений задач в читаемые названия
  taskLabels = {
    portraitRetouching: "Ретушь портрета",
    colorCorrection: "Цветокоррекция",
    improvePhotoQuality: "Улучшить качество фото",
    preparationForPrinting: "Подготовка к печати",
    socialMediaContent: "Контент для соцсетей",
    advertisingProcessing: "Рекламная обработка",
    stylization: "Стилизация",
    backgroundEditing: "Редактирование фона",
    graphicContent: "Графический контент",
    setLight: "Настройка света",
    simulation3d: "Симуляция 3D",
    atmosphereWeather: "Атмосфера и погода",
  };

  // Словарь для перевода значений программ в читаемые названия
  programLabels = {
    photoshop: "Photoshop",
    lightroom: "Lightroom",
    after_effects: "After Effects",
    illustrator: "Illustrator",
    premiere_pro: "Premiere Pro",
    blender: "Blender",
    affinity_photo: "Affinity Photo",
    capture_one: "Capture One",
    maya: "Maya",
    cinema_4d: "Cinema 4D",
    "3ds_max": "3ds Max",
    zbrush: "ZBrush",
  };

  // Словарь для платформ
  platformLabels = {
    windows: "Windows",
    mac: "Mac",
    linux: "Linux",
    web: "Веб",
    mobile: "Мобильные",
  };

  // Словарь иконок программ
  programIcons = {
    photoshop: "/assets/photoshop_icon.svg",
    lightroom: "/assets/lightroom_icon.svg",
    after_effects: "/assets/after_effects_icon.svg",
    illustrator: "/assets/illustrator_icon.svg",
    premiere_pro: "/assets/premiere_icon.svg",
    blender: "/assets/blender_icon.svg",
    affinity_photo: "/assets/affinity_photo_icon.svg",
    capture_one: "/assets/capture_one_icon.svg",
    maya: "/assets/maya_icon.svg",
    cinema_4d: "/assets/cinema_4d_icon.svg",
    "3ds_max": "/assets/3ds_max_icon.svg",
    zbrush: "/assets/zbrush_icon.svg",
  };

  // Получение иконки программы
  getProgramIcon(programValue) {
    return this.programIcons[programValue];
  }

  connect() {
    // Закрыть выпадающие меню при клике вне их
    document.addEventListener("click", this.handleOutsideClick.bind(this));
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  }

  // Управление выпадающим списком задач
  toggleTasks(event) {
    event.preventDefault();

    if (this.hasTaskDropdownTarget) {
      const isVisible = this.taskDropdownTarget.style.display !== "none";

      // Закрываем другие dropdown'ы
      this.closeAllDropdowns();

      if (!isVisible) {
        this.taskDropdownTarget.style.display = "block";
      }
    }
  }

  // Управление выпадающим списком программ
  togglePrograms(event) {
    event.preventDefault();

    if (this.hasProgramDropdownTarget) {
      const isVisible = this.programDropdownTarget.style.display !== "none";

      // Закрываем другие dropdown'ы
      this.closeAllDropdowns();

      if (!isVisible) {
        this.programDropdownTarget.style.display = "block";
      }
    }
  }

  // Управление выпадающим списком платформ
  togglePlatforms(event) {
    event.preventDefault();

    if (this.hasPlatformDropdownTarget) {
      const isVisible = this.platformDropdownTarget.style.display !== "none";

      // Закрываем другие dropdown'ы
      this.closeAllDropdowns();

      if (!isVisible) {
        this.platformDropdownTarget.style.display = "block";
      }
    }
  }

  // Закрытие всех выпадающих списков
  closeAllDropdowns() {
    if (this.hasTaskDropdownTarget) {
      this.taskDropdownTarget.style.display = "none";
    }
    if (this.hasProgramDropdownTarget) {
      this.programDropdownTarget.style.display = "none";
    }
    if (this.hasPlatformDropdownTarget) {
      this.platformDropdownTarget.style.display = "none";
    }
  }

  // Обработка клика вне элементов
  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.closeAllDropdowns();
    }
  }

  // Обработка выбора задач
  selectTask(event) {
    const checkbox = event.target;
    if (checkbox.type === "checkbox") {
      this.updateSelectedTasksDisplay();
    }
  }

  // Обработка выбора программ
  selectProgram(event) {
    const checkbox = event.target;
    if (checkbox.type === "checkbox") {
      this.updateSelectedProgramsDisplay();
    }
  }

  // Обработка выбора платформ
  selectPlatform(event) {
    const checkbox = event.target;
    if (checkbox.type === "checkbox") {
      this.updateSelectedPlatformsDisplay();
    }
  }

  // Обновление отображения выбранных задач
  updateSelectedTasksDisplay() {
    if (!this.hasSelectedTasksTarget || !this.hasSelectedTasksListTarget) {
      return;
    }

    const selectedCheckboxes = this.element.querySelectorAll(
      'input[name*="task"]:checked'
    );
    const container = this.selectedTasksTarget;
    const list = this.selectedTasksListTarget;

    if (selectedCheckboxes.length > 0) {
      list.innerHTML = "";
      selectedCheckboxes.forEach((checkbox) => {
        const taskValue = checkbox.value;
        const taskLabel = this.taskLabels[taskValue] || taskValue;

        const tagElement = document.createElement("div");
        tagElement.className = "O_SelectedCategoryTag";
        tagElement.innerHTML = `
          <span>${taskLabel}</span>
          <button class="Q_RemoveCategoryButton" data-task="${taskValue}" data-action="effect-tags#removeTask">
            <img src="/assets/CancelFilter.svg" alt="Удалить" class="Q_CancelFilterIcon">
          </button>
        `;
        list.appendChild(tagElement);
      });
      container.style.display = "block";
    } else {
      container.style.display = "none";
    }
  }

  // Обновление отображения выбранных программ
  updateSelectedProgramsDisplay() {
    if (
      !this.hasSelectedProgramsTarget ||
      !this.hasSelectedProgramsListTarget
    ) {
      return;
    }

    const selectedCheckboxes = this.element.querySelectorAll(
      'input[name*="program"]:checked'
    );
    const container = this.selectedProgramsTarget;
    const list = this.selectedProgramsListTarget;

    if (selectedCheckboxes.length > 0) {
      list.innerHTML = "";
      selectedCheckboxes.forEach((checkbox) => {
        const programValue = checkbox.value;
        const programLabel = this.programLabels[programValue] || programValue;
        const programIcon = this.getProgramIcon(programValue);

        // Создаем контейнер для программы и её версии
        const programContainer = document.createElement("div");
        programContainer.className = "W_ProgramWithVersion";
        programContainer.style.cssText =
          "display: flex; align-items: center; gap: 0.5vw; flex-wrap: wrap; flex-direction: row;";

        // Создаем тег программы
        const tagElement = document.createElement("div");
        tagElement.className =
          "O_SelectedCategoryTag O_SelectedCategoryProgram";
        tagElement.innerHTML = `
          <div class="Q_ProgramItemContent">
            ${
              programIcon
                ? `<img src="${programIcon}" alt="${programLabel}" class="Q_ProgramIconDropdown">`
                : ""
            }
            <span>${programLabel}</span>
          </div>
          <button class="Q_RemoveCategoryButton" data-program="${programValue}" data-action="effect-tags#removeProgram">
            <img src="/assets/CancelFilter.svg" alt="Удалить" class="Q_CancelFilterIcon">
          </button>
        `;

        // Создаем скрытое поле с именем программы
        const programNameInput = document.createElement("input");
        programNameInput.type = "hidden";
        programNameInput.name = `effect[effect_programs_attributes][${programValue}][name]`;
        programNameInput.value = programValue;

        // Создаем поле версии для этой программы
        const versionInput = document.createElement("input");
        versionInput.type = "text";
        versionInput.className = "A_Input A_InputVersion";
        versionInput.placeholder = "Минимальная версия";
        versionInput.name = `effect[effect_programs_attributes][${programValue}][version]`;
        versionInput.style.cssText = "width: 11.979vw;";

        // Добавляем элементы в контейнер
        programContainer.appendChild(tagElement);
        programContainer.appendChild(programNameInput);
        programContainer.appendChild(versionInput);

        list.appendChild(programContainer);
      });
      container.style.display = "block";
    } else {
      container.style.display = "none";
    }
  }

  // Обновление отображения выбранных платформ
  updateSelectedPlatformsDisplay() {
    if (
      !this.hasSelectedPlatformsTarget ||
      !this.hasSelectedPlatformsListTarget
    ) {
      return;
    }

    const selectedCheckboxes = this.element.querySelectorAll(
      'input[name*="platform"]:checked'
    );
    const container = this.selectedPlatformsTarget;
    const list = this.selectedPlatformsListTarget;

    if (selectedCheckboxes.length > 0) {
      list.innerHTML = "";
      selectedCheckboxes.forEach((checkbox) => {
        const platformValue = checkbox.value;
        const platformLabel =
          this.platformLabels[platformValue] || platformValue;

        const tagElement = document.createElement("div");
        tagElement.className = "O_SelectedCategoryTag";
        tagElement.innerHTML = `
          <span>${platformLabel}</span>
          <button class="Q_RemoveCategoryButton" data-platform="${platformValue}" data-action="effect-tags#removePlatform">
            <img src="/assets/CancelFilter.svg" alt="Удалить" class="Q_CancelFilterIcon">
          </button>
        `;
        list.appendChild(tagElement);
      });
      container.style.display = "block";
    } else {
      container.style.display = "none";
    }
  }

  // Удаление отдельной задачи
  removeTask(event) {
    event.preventDefault();

    const button = event.target.closest("button[data-task]");
    if (!button) return;

    const taskValue = button.dataset.task;
    const checkbox = this.element.querySelector(`input[value="${taskValue}"]`);

    if (checkbox) {
      checkbox.checked = false;
      this.updateSelectedTasksDisplay();
    }
  }

  // Удаление отдельной программы
  removeProgram(event) {
    event.preventDefault();

    const button = event.target.closest("button[data-program]");
    if (!button) return;

    const programValue = button.dataset.program;
    const checkbox = this.element.querySelector(
      `input[value="${programValue}"]`
    );

    if (checkbox) {
      checkbox.checked = false;
      this.updateSelectedProgramsDisplay();
    }
  }

  // Удаление отдельной платформы
  removePlatform(event) {
    event.preventDefault();

    const button = event.target.closest("button[data-platform]");
    if (!button) return;

    const platformValue = button.dataset.platform;
    const checkbox = this.element.querySelector(
      `input[value="${platformValue}"]`
    );

    if (checkbox) {
      checkbox.checked = false;
      this.updateSelectedPlatformsDisplay();
    }
  }
}
