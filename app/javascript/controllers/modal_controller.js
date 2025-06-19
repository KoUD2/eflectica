// app/javascript/controllers/modal_controller.js

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal", "content", "step1", "step2", "step3", "form"];

  connect() {
    this.step = 1;
    this.selectedCategories = [];
    this.selectedPrograms = [];
    this.updateProgressBar();
  }

  open() {
    // Сбрасываем состояние модального окна
    this.step = 1;
    this.selectedCategories = [];
    this.selectedPrograms = [];

    // Сбрасываем контент к первому шагу (категории)
    this.resetToStep1();

    this.modalTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";

    this.updateProgressBar();
  }

  next() {
    console.log(`=== NEXT called, current step: ${this.step} ===`);

    // Сохраняем выбранные значения перед переходом к следующему шагу
    if (this.step === 1) {
      // Сохраняем выбранные категории
      this.selectedCategories = Array.from(
        document.querySelectorAll('input[name="categories[]"]:checked')
      ).map((checkbox) => checkbox.value);
      console.log("Saved categories:", this.selectedCategories);
    } else if (this.step === 2) {
      // Сохраняем выбранные программы
      this.selectedPrograms = Array.from(
        document.querySelectorAll('input[name="programs[]"]:checked')
      ).map((checkbox) => checkbox.value);
      console.log("Saved programs:", this.selectedPrograms);
    }

    this.step += 1;
    console.log(`Moving to step: ${this.step}`);

    if (this.step === 2) {
      console.log("Updating content to step 2 (Programs)");

      // Получаем данные о программах из data-атрибута
      const programsDataElement = document.getElementById("programs-data");
      let programs = [];

      if (programsDataElement) {
        try {
          const programsData = programsDataElement.dataset.programs;
          console.log("Raw programs data:", programsData);

          if (programsData) {
            programs = JSON.parse(programsData);
            console.log("Parsed programs:", programs);
          }
        } catch (error) {
          console.error("Error parsing programs data:", error);
        }
      }

      this.updateContent(
        "Программы",
        "Будем преимущественно показывать эффекты с этими программами",
        programs
      );
    } else if (this.step === 3) {
      console.log("Updating content to step 3 (Subscriptions)");
      this.updateContentStep3();
    }

    this.updateProgressBar();
  }

  updateProgressBar() {
    const progressFill = document.querySelector(".Q_ProgressFill");

    if (progressFill) {
      const percentage = (this.step / 3) * 100;
      progressFill.style.width = `${percentage}%`;
    }
  }

  updateContentStep3() {
    this.contentTarget.innerHTML = `
      <h2 class='A_Header2'>Подписки</h2>
      <p class='A_TextEffectDescription A_TextEffectDescriptionSettingsFeedFinal'>
        В ленте автоматически появятся эффекты из подписок. Ты можешь перейти в раздел коллекций сейчас или найти подписки позже.
      </p>
      <div class="A_More">
        <a href="/news_feeds" class="A_LinkPrimary" class="A_TextButtonPrimary">Перейти к подпискам</a>
        <img src="/assets/ArrowIcon.svg" alt="ArrowIcon.svg" class="Q_arrowFollow"  
      </div>
    `;

    const button = document.querySelector(".A_ButtonPrimaryClose");
    button.textContent = "Завершить настройку";
    button.setAttribute("data-action", "modal#saveAndClose");
  }

  saveAndClose() {
    console.log("=== saveAndClose started ===");

    // Собираем данные формы
    const formData = new FormData();

    // Используем сохраненные значения вместо поиска в DOM
    console.log("=== JS DEBUG ===");
    console.log("Selected categories:", this.selectedCategories);
    console.log("Selected programs:", this.selectedPrograms);

    // Проверяем наличие CSRF токена
    const csrfToken = document.querySelector('[name="csrf-token"]');
    console.log("CSRF token element:", csrfToken);
    console.log(
      "CSRF token content:",
      csrfToken ? csrfToken.content : "NOT FOUND"
    );

    // Добавляем данные в formData
    this.selectedCategories.forEach((category) =>
      formData.append("categories[]", category)
    );
    this.selectedPrograms.forEach((program) =>
      formData.append("programs[]", program)
    );

    console.log("Sending request to /effects/save_preferences");

    // Отправляем данные на сервер
    fetch("/effects/save_preferences", {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": csrfToken ? csrfToken.content : "",
      },
    })
      .then((response) => {
        console.log("Response received:", response);
        console.log("Response status:", response.status);
        console.log("Response ok:", response.ok);

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        return response.json();
      })
      .then((data) => {
        console.log("Response data:", data);
        if (data.status === "success") {
          console.log("Success! Data saved successfully!");
          this.close();
          window.location.reload();
        } else {
          console.error("Ошибка сохранения:", data.message);
        }
      })
      .catch((error) => {
        console.error("Fetch error:", error);
        console.error("Error details:", error.message);
      });
  }

  updateContent(header, description, items) {
    // Получаем текущие предпочтения пользователя
    const programsDataElement = document.getElementById("programs-data");
    let userPrograms = [];

    if (programsDataElement) {
      try {
        const userProgramsData = programsDataElement.dataset.userPrograms;
        if (userProgramsData && userProgramsData.trim() !== "") {
          userPrograms = JSON.parse(userProgramsData);
        }
      } catch (error) {
        console.error("Error parsing user programs:", error);
        userPrograms = [];
      }
    }

    this.contentTarget.innerHTML = `
      <h2 class='A_Header2'>${header}</h2>
      <p class='A_TextEffectDescription A_TextEffectDescriptionSettingsFeed'>${description}</p>
      <ul class="C_Choice C_ChoiceFeed">
        ${items
          .map((item) => {
            const programKey = item.key;
            const programName = item.name;
            const iconPath = item.icon;
            const isChecked = userPrograms.includes(programKey)
              ? "checked"
              : "";
            return `
            <li class="M_Choice M_ChoiceEffect">
              <label class="custom-checkbox">
                <div class="W_nameImg">
                  <img src="/assets/${iconPath}" alt="${programKey}" class="Q_ProgramIconFeed" />
                  <p class="A_TextButtonSeсondary A_TextButtonSeсondaryBlack">
                    ${programName}
                  </p>
                </div>
                <input type="checkbox" name="programs[]" value="${programKey}" ${isChecked} />
                <span class="checkmark"></span>
              </label>
            </li>`;
          })
          .join("")}
        <li class="M_Choice M_ChoiceEffect">
          <label class="custom-checkbox">
            <p class="A_TextButtonSeсondary A_TextButtonSeсondaryBlack">
              Отметить все
            </p>
            <input type="checkbox" name="programs[]" value="all" />
            <span class="checkmark"></span>
          </label>
        </li>
      </ul>`;
  }

  resetToStep1() {
    // Сбрасываем контент к первому шагу (категории)
    // Находим элемент контента и восстанавливаем оригинальный HTML с категориями
    const contentElement = this.contentTarget;
    if (contentElement) {
      contentElement.innerHTML = `
        <h2 class="A_Header2">Категории</h2>
        <p class="A_TextEffectDescription A_TextEffectDescriptionSettingsFeed">
          Выбери одно или несколько направлений, в которых ты работаешь
        </p>
        <ul class="C_Choice C_ChoiceFeed">
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">Обработка фото</p>
              <input type="checkbox" name="categories[]" value="photoProcessing" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">3D-графика</p>
              <input type="checkbox" name="categories[]" value="3dGrafics" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">Моушен</p>
              <input type="checkbox" name="categories[]" value="motion" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">Иллюстрация</p>
              <input type="checkbox" name="categories[]" value="illustration" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">Анимация</p>
              <input type="checkbox" name="categories[]" value="animation" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">UI/UX-анимация</p>
              <input type="checkbox" name="categories[]" value="uiux" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">Обработка видео</p>
              <input type="checkbox" name="categories[]" value="videoProcessing" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">VFX</p>
              <input type="checkbox" name="categories[]" value="vfx" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">Геймдев</p>
              <input type="checkbox" name="categories[]" value="gamedev" />
              <span class="checkmark"></span>
            </label>
          </li>
          <li class="M_Choice M_ChoiceEffect">
            <label class="custom-checkbox">
              <p class="A_TextButtonSeсондary A_TextButtonSeсондaryBlack">AR & VR</p>
              <input type="checkbox" name="categories[]" value="arvr" />
              <span class="checkmark"></span>
            </label>
          </li>
        </ul>
      `;

      // Устанавливаем checked состояния для текущих предпочтений пользователя
      // Добавляем небольшую задержку чтобы убедиться что DOM обновлен
      setTimeout(() => {
        this.setUserPreferences();
      }, 100);
    }

    // Сбрасываем кнопку "Дальше"
    const button = document.querySelector(".A_ButtonPrimaryClose");
    if (button) {
      button.textContent = "Дальше";
      button.setAttribute("data-action", "modal#next");
    }
  }

  setUserPreferences() {
    // Получаем данные о пользовательских предпочтениях
    const programsDataElement = document.getElementById("programs-data");
    console.log("Programs data element:", programsDataElement);

    if (programsDataElement) {
      const userCategoriesData = programsDataElement.dataset.userCategories;
      console.log("Raw user categories data:", userCategoriesData);
      console.log("Type of userCategoriesData:", typeof userCategoriesData);
      console.log(
        "userCategoriesData length:",
        userCategoriesData ? userCategoriesData.length : "N/A"
      );

      let userCategories = [];

      // Более надежная проверка данных
      if (
        userCategoriesData &&
        userCategoriesData !== "undefined" &&
        userCategoriesData !== "null" &&
        userCategoriesData.trim() !== "" &&
        userCategoriesData.length > 0
      ) {
        try {
          userCategories = JSON.parse(userCategoriesData);
          console.log("Successfully parsed user categories:", userCategories);
        } catch (error) {
          console.error("Error parsing user categories:", error);
          console.log("Using empty array instead");
          userCategories = [];
        }
      } else {
        console.log(
          "User categories data is empty or invalid, using empty array"
        );
      }

      // Устанавливаем checked для категорий
      if (userCategories.length > 0) {
        userCategories.forEach((category) => {
          const checkbox = document.querySelector(
            `input[name="categories[]"][value="${category}"]`
          );
          if (checkbox) {
            checkbox.checked = true;
            console.log(`Set checked for category: ${category}`);
          } else {
            console.log(`Checkbox not found for category: ${category}`);
          }
        });
      } else {
        console.log("No user categories to set");
      }
    } else {
      console.log("Programs data element not found");
    }
  }

  close() {
    this.modalTarget.classList.add("hidden");
    document.body.style.overflow = "";
  }
}
