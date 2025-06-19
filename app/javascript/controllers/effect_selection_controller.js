import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { collectionId: String };

  connect() {
    this.changedEffects = new Map(); // Map<effectId, 'add'|'remove'>
    this.saveButton = document.getElementById("saveSelectedEffects");

    // Инициализируем состояние на основе уже отмеченных чекбоксов
    this.initializeState();

    // Если мы в режиме выбора для коллекции, показываем кнопку сохранения
    if (this.hasCollectionIdValue) {
      this.updateSaveButtonVisibility();
    }

    // Добавляем обработчик для кнопки сохранения
    if (this.saveButton) {
      this.saveButton.addEventListener("click", () => {
        this.saveChanges();
      });
    }
  }

  initializeState() {
    // Запоминаем изначальное состояние всех чекбоксов
    this.initialState = new Map();
    const checkboxes = this.element.querySelectorAll(".effect-checkbox");
    checkboxes.forEach((checkbox) => {
      const effectId = checkbox.getAttribute("data-effect-id");
      this.initialState.set(effectId, checkbox.checked);
    });
  }

  toggleEffect(event) {
    const checkbox = event.target;
    const effectId = checkbox.getAttribute("data-effect-id");
    const isChecked = checkbox.checked;
    const wasInitiallyChecked = this.initialState.get(effectId);

    console.log(`=== Effect Toggle Debug ===`);
    console.log(`Effect ID: ${effectId}`);
    console.log(`Was initially checked: ${wasInitiallyChecked}`);
    console.log(`Is now checked: ${isChecked}`);

    // Определяем, что нужно делать с эффектом
    if (isChecked && !wasInitiallyChecked) {
      // Добавить эффект в коллекцию
      console.log(`Action: ADD effect to collection`);
      this.changedEffects.set(effectId, "add");
    } else if (!isChecked && wasInitiallyChecked) {
      // Удалить эффект из коллекции
      console.log(`Action: REMOVE effect from collection`);
      this.changedEffects.set(effectId, "remove");
    } else {
      // Вернули в исходное состояние
      console.log(`Action: RESET to initial state`);
      this.changedEffects.delete(effectId);
    }

    console.log(`Changed effects:`, Array.from(this.changedEffects.entries()));
    this.updateSaveButtonVisibility();
  }

  updateSaveButtonVisibility() {
    if (this.saveButton) {
      if (this.changedEffects.size > 0) {
        this.saveButton.style.display = "block";

        const addCount = Array.from(this.changedEffects.values()).filter(
          (action) => action === "add"
        ).length;
        const removeCount = Array.from(this.changedEffects.values()).filter(
          (action) => action === "remove"
        ).length;

        let text = "Сохранить изменения";
        if (addCount > 0 && removeCount > 0) {
          text = `Сохранить выбор`;
        } else if (addCount > 0) {
          text = `Сохранить выбор`;
        } else if (removeCount > 0) {
          text = `Сохранить выбор`;
        }

        this.saveButton.textContent = text;
      } else {
        this.saveButton.style.display = "none";
      }
    }
  }

  saveChanges() {
    if (this.changedEffects.size === 0) {
      return;
    }

    const collectionId = this.saveButton.getAttribute("data-collection-id");

    // Разделяем эффекты на добавление и удаление
    const effectsToAdd = [];
    const effectsToRemove = [];

    this.changedEffects.forEach((action, effectId) => {
      if (action === "add") {
        effectsToAdd.push(effectId);
      } else if (action === "remove") {
        effectsToRemove.push(effectId);
      }
    });

    // Отправляем AJAX запрос для обновления коллекции
    fetch(`/collection/${collectionId}/effects/bulk_update`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({
        add_effect_ids: effectsToAdd,
        remove_effect_ids: effectsToRemove,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          // Перенаправляем обратно в коллекцию без alert
          window.location.href = `/collection/${collectionId}`;
        } else {
          alert(
            "Ошибка при сохранении: " + (data.error || "Неизвестная ошибка")
          );
        }
      })
      .catch((error) => {
        console.error("Error:", error);
        alert("Произошла ошибка при сохранении");
      });
  }
}
