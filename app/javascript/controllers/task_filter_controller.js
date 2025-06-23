import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "dropdown",
    "toggleButton",
    "effectSection",
    "selectedTasks",
    "selectedTasksList",
    "programDropdown",
    "programToggleButton",
    "selectedPrograms",
    "selectedProgramsList",
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
    premiere_pro: "Premiere Pro",
    blender: "Blender",
    affinity_photo: "Affinity Photo",
    capture_one: "Capture One",
    maya: "Maya",
    cinema_4d: "Cinema 4D",
    "3ds_max": "3ds Max",
    zbrush: "ZBrush",
    unreal: "Unreal Engine",
    davinci: "DaVinci Resolve",
    substance: "Substance Painter",
    protopie: "ProtoPie",
    krita: "Krita",
    sketch: "Sketch",
    animate: "Adobe Animate",
    figma: "Figma",
    clip: "Clip Studio Paint",
    nuke: "Nuke",
    fc: "Final Cut Pro",
    procreate: "Procreate",
    godot: "Godot",
    lens: "Lens Studio",
    rive: "Rive",
    unity: "Unity",
    spark: "Spark AR",
    spine: "Spine",
    toon: "Toon Boom Harmony",
  };

  // Словарь иконок программ
  programIcons = {
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

  connect() {
    // Закрыть выпадающее меню при клике вне его
    document.addEventListener("click", this.handleOutsideClick.bind(this));

    // Очищаем состояние фильтров при инициализации
    this.clearFiltersOnInit();
  }

  clearFiltersOnInit() {
    // Проверяем, есть ли параметр collection_id в URL (режим выбора эффектов)
    const urlParams = new URLSearchParams(window.location.search);
    const collectionId = urlParams.get("collection_id");

    if (collectionId) {
      // В режиме выбора эффектов очищаем все фильтры
      this.clearAllFilters();
    }
  }

  clearAllFilters() {
    // Очищаем все чекбоксы задач
    const taskCheckboxes = this.element.querySelectorAll(
      'input[type="checkbox"]'
    );
    taskCheckboxes.forEach((checkbox) => {
      checkbox.checked = false;
    });

    // Очищаем отображение выбранных задач
    if (this.hasSelectedTasksTarget) {
      this.selectedTasksTarget.style.display = "none";
    }
    if (this.hasSelectedTasksListTarget) {
      this.selectedTasksListTarget.innerHTML = "";
    }

    // Очищаем отображение выбранных программ
    if (this.hasSelectedProgramsTarget) {
      this.selectedProgramsTarget.style.display = "none";
    }
    if (this.hasSelectedProgramsListTarget) {
      this.selectedProgramsListTarget.innerHTML = "";
    }

    // Показываем все эффекты
    if (this.hasEffectSectionTarget) {
      const effectCards = this.effectSectionTarget.querySelectorAll(
        ".O_EffectCollectionCard"
      );
      effectCards.forEach((card) => {
        card.style.display = "flex";
      });
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  }

  toggle(event) {
    event.preventDefault();
    const dropdown = this.dropdownTarget;
    const isVisible = dropdown.style.display !== "none";

    // Закрываем dropdown программ если он открыт
    if (this.hasProgramDropdownTarget) {
      this.programDropdownTarget.style.display = "none";
    }

    if (isVisible) {
      dropdown.style.display = "none";
    } else {
      dropdown.style.display = "block";
    }
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.style.display = "none";
      if (this.hasProgramDropdownTarget) {
        this.programDropdownTarget.style.display = "none";
      }
    }
  }

  togglePrograms(event) {
    event.preventDefault();
    const dropdown = this.programDropdownTarget;
    const isVisible = dropdown.style.display !== "none";

    // Закрываем dropdown задач если он открыт
    if (this.hasDropdownTarget) {
      this.dropdownTarget.style.display = "none";
    }

    if (isVisible) {
      dropdown.style.display = "none";
    } else {
      dropdown.style.display = "block";
    }
  }

  // Метод для удаления отдельной задачи
  removeTask(event) {
    event.preventDefault();

    // Находим кнопку, даже если клик был по изображению внутри кнопки
    const button = event.target.closest("button[data-task]");
    if (!button) {
      console.error("Button with data-task not found");
      return;
    }

    const taskValue = button.dataset.task;
    console.log("Removing task:", taskValue);

    // Находим и снимаем соответствующий чекбокс
    const checkbox = this.element.querySelector(`input[value="${taskValue}"]`);
    if (checkbox) {
      checkbox.checked = false;
      console.log("Checkbox unchecked for task:", taskValue);
    } else {
      console.error("Checkbox not found for task:", taskValue);
    }

    // Обновляем отображение и применяем фильтрацию
    this.filterEffects();
  }

  // Метод для обновления отображения выбранных задач
  updateSelectedTasksDisplay(selectedTasks) {
    if (!this.hasSelectedTasksTarget || !this.hasSelectedTasksListTarget) {
      return;
    }

    const container = this.selectedTasksTarget;
    const list = this.selectedTasksListTarget;

    if (selectedTasks.length === 0) {
      // Скрываем контейнер если нет выбранных задач
      container.style.display = "none";
      list.innerHTML = "";
    } else {
      // Показываем контейнер
      container.style.display = "flex";

      // Создаем элементы для каждой выбранной задачи
      const taskElements = selectedTasks
        .map((task) => {
          const label = this.taskLabels[task] || task;
          return `
          <div class="O_SelectedCategoryTag">
            <span>${label}</span>
            <button class="Q_RemoveCategoryButton" data-action="task-filter#removeTask" data-task="${task}">
              <img src="/assets/CancelFilter.svg" alt="Удалить" class="Q_CancelFilterIcon">
            </button>
          </div>
        `;
        })
        .join("");

      list.innerHTML = taskElements;
    }
  }

  filterEffects(event) {
    const selectedTasks = [];
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"]:checked'
    );

    checkboxes.forEach((checkbox) => {
      selectedTasks.push(checkbox.value);
    });

    console.log("=== TASK FILTER DEBUG ===");
    console.log("Selected tasks:", selectedTasks);

    // Обновляем отображение выбранных задач
    this.updateSelectedTasksDisplay(selectedTasks);

    // Фильтруем эффекты по выбранным задачам
    const effectSection = this.effectSectionTarget;
    const effectCards = effectSection.querySelectorAll(
      ".O_EffectCollectionCard"
    );

    console.log("Found effect cards:", effectCards.length);

    let visibleEffectsCount = 0;

    effectCards.forEach((card, index) => {
      const effectTasks = card.dataset.tasks
        ? card.dataset.tasks.split(",").map((task) => task.trim())
        : [];

      console.log(`Effect ${index + 1}:`, {
        name: card.dataset.name,
        tasks: effectTasks,
        tasksRaw: card.dataset.tasks,
      });

      if (selectedTasks.length === 0) {
        // Если ничего не выбрано - показать все эффекты
        card.style.display = "flex";
        visibleEffectsCount++;
      } else {
        // При фильтрации показать только эффекты, которые принадлежат к выбранным задачам
        const hasMatchingTask = effectTasks.some((task) =>
          selectedTasks.includes(task)
        );

        console.log(`Effect ${index + 1} has matching task:`, hasMatchingTask);

        if (hasMatchingTask) {
          card.style.display = "flex";
          visibleEffectsCount++;
        } else {
          card.style.display = "none";
        }
      }
    });

    console.log("Visible effects count:", visibleEffectsCount);
    console.log("=== END DEBUG ===");
  }

  // Метод для удаления отдельной программы
  removeProgram(event) {
    event.preventDefault();

    // Находим кнопку, даже если клик был по изображению внутри кнопки
    const button = event.target.closest("button[data-program]");
    if (!button) {
      console.error("Button with data-program not found");
      return;
    }

    const programValue = button.dataset.program;
    console.log("Removing program:", programValue);

    // Находим и снимаем соответствующий чекбокс
    const checkbox = this.element.querySelector(
      `input[value="${programValue}"]`
    );
    if (checkbox) {
      checkbox.checked = false;
      console.log("Checkbox unchecked for program:", programValue);
    } else {
      console.error("Checkbox not found for program:", programValue);
    }

    // Обновляем отображение и применяем фильтрацию
    this.filterByPrograms();
  }

  // Метод для обновления отображения выбранных программ
  updateSelectedProgramsDisplay(selectedPrograms) {
    if (
      !this.hasSelectedProgramsTarget ||
      !this.hasSelectedProgramsListTarget
    ) {
      return;
    }

    const container = this.selectedProgramsTarget;
    const list = this.selectedProgramsListTarget;

    if (selectedPrograms.length === 0) {
      // Скрываем контейнер если нет выбранных программ
      container.style.display = "none";
      list.innerHTML = "";
    } else {
      // Показываем контейнер
      container.style.display = "flex";

      // Создаем элементы для каждой выбранной программы
      const programElements = selectedPrograms
        .map((program) => {
          const label = this.programLabels[program] || program;
          const icon = this.programIcons[program] || "";
          const iconHtml = icon
            ? `<img src="${icon}" alt="${label}" class="Q_ProgramIconImage">`
            : "";
          return `
          <div class="O_SelectedCategoryTag">
            <div class="W_SelectedCategoryTag">
            ${iconHtml}<span>${label}</span></div>
            <button class="Q_RemoveCategoryButton" data-action="task-filter#removeProgram" data-program="${program}">
              <img src="/assets/CancelFilter.svg" alt="Удалить" class="Q_CancelFilterIcon">
            </button>
          </div>
        `;
        })
        .join("");

      list.innerHTML = programElements;
    }
  }

  filterByPrograms(event) {
    const selectedPrograms = [];
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"]:checked'
    );

    checkboxes.forEach((checkbox) => {
      // Проверяем, что это чекбокс программы (находится в programDropdown)
      if (this.programDropdownTarget.contains(checkbox)) {
        selectedPrograms.push(checkbox.value);
      }
    });

    console.log("=== PROGRAM FILTER DEBUG ===");
    console.log("Selected programs:", selectedPrograms);

    // Обновляем отображение выбранных программ
    this.updateSelectedProgramsDisplay(selectedPrograms);

    // Фильтруем эффекты по выбранным программам
    const effectSection = this.effectSectionTarget;
    const effectCards = effectSection.querySelectorAll(
      ".O_EffectCollectionCard"
    );

    console.log("Found effect cards:", effectCards.length);

    let visibleEffectsCount = 0;

    effectCards.forEach((card, index) => {
      const effectPrograms = card.dataset.programs
        ? card.dataset.programs.split(",").map((program) => program.trim())
        : [];

      console.log(`Effect ${index + 1}:`, {
        name: card.dataset.name,
        programs: effectPrograms,
        programsRaw: card.dataset.programs,
      });

      if (selectedPrograms.length === 0) {
        // Если ничего не выбрано - показать все эффекты
        card.style.display = "flex";
        visibleEffectsCount++;
      } else {
        // При фильтрации показать только эффекты, которые принадлежат к выбранным программам
        const hasMatchingProgram = effectPrograms.some((program) =>
          selectedPrograms.includes(program)
        );

        console.log(
          `Effect ${index + 1} has matching program:`,
          hasMatchingProgram
        );

        if (hasMatchingProgram) {
          card.style.display = "flex";
          visibleEffectsCount++;
        } else {
          card.style.display = "none";
        }
      }
    });

    console.log("Visible effects count:", visibleEffectsCount);
    console.log("=== END PROGRAM DEBUG ===");
  }
}
