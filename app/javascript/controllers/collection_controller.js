import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "fileName",
    "backdrop",
    "effectSection",
    "linkSection",
    "referenceSection",
    "linkName",
    "linkNotes",
    "linkUrl",
    "addLinkButton",
    "addReferenceButton",
    "referenceTitle",
    "referenceNotes",
    "currentFileSection",
    "currentFileName",
  ];

  connect() {
    // Инициализируем валидацию форм при загрузке
    this.validateLinkForm();
    this.validateReferenceForm();
  }

  open() {
    this.backdropTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  close() {
    this.backdropTarget.classList.add("hidden");
    document.body.style.overflow = "";
  }

  updateForm(event) {
    const selectedValue = event.target.value;

    // Скрываем все секции
    this.effectSectionTarget.classList.add("hidden");
    this.linkSectionTarget.classList.add("hidden");
    this.referenceSectionTarget.classList.add("hidden");

    // Показываем нужную секцию
    if (selectedValue === "effect") {
      this.effectSectionTarget.classList.remove("hidden");
    } else if (selectedValue === "link") {
      this.linkSectionTarget.classList.remove("hidden");
    } else if (selectedValue === "reference") {
      this.referenceSectionTarget.classList.remove("hidden");
    }
  }

  updateFileName(event) {
    const files = event.target.files;
    if (files.length > 0) {
      this.fileNameTarget.textContent = files[0].name; // Обновляем текст на название файла
      this.fileNameTarget.classList.remove("default-color"); // Убираем серый цвет
      this.fileNameTarget.classList.add("active-color"); // Добавляем черный цвет
    } else {
      this.fileNameTarget.textContent = "Выбери файл"; // Возвращаем текст по умолчанию
      this.fileNameTarget.classList.remove("active-color"); // Убираем черный цвет
      this.fileNameTarget.classList.add("default-color"); // Возвращаем серый цвет
    }

    // Обновляем валидацию формы референса
    this.validateReferenceForm();
  }

  previewImage(event) {
    // This method is intentionally left empty to prevent image preview
    // We're keeping the original paperclip icon regardless of file selection
  }

  selectNewFile() {
    // Триггерим клик по скрытому input file
    const fileInput = document.getElementById("file_upload");
    if (fileInput) {
      fileInput.click();
    }
  }

  validateLinkForm() {
    // Проверяем заполнение обязательных полей для ссылки
    const name = this.linkNameTarget.value.trim();
    const url = this.linkUrlTarget.value.trim();

    // Кнопка активна только если обязательные поля заполнены
    const isValid = name.length > 0 && url.length > 0;

    this.addLinkButtonTarget.disabled = !isValid;

    if (isValid) {
      this.addLinkButtonTarget.classList.remove("A_ButtonDisabled");
    } else {
      this.addLinkButtonTarget.classList.add("A_ButtonDisabled");
    }
  }

  validateReferenceForm() {
    // Проверяем название и файл
    const title = this.hasReferenceTitleTarget
      ? this.referenceTitleTarget.value.trim()
      : "";
    const fileInput = document.getElementById("file_upload");
    const hasFile = fileInput && fileInput.files.length > 0;

    // Кнопка активна только если есть название и файл
    const isValid = title.length > 0 && hasFile;

    if (this.hasAddReferenceButtonTarget) {
      this.addReferenceButtonTarget.disabled = !isValid;

      if (isValid) {
        this.addReferenceButtonTarget.classList.remove("A_ButtonDisabled");
      } else {
        this.addReferenceButtonTarget.classList.add("A_ButtonDisabled");
      }
    }
  }

  addLink() {
    // Получаем данные из формы
    const name = this.linkNameTarget.value.trim();
    const notes = this.linkNotesTarget.value.trim();
    const linkUrl = this.linkUrlTarget.value.trim();

    if (!name || !linkUrl) {
      alert("Пожалуйста, заполните название и URL");
      return;
    }

    // Получаем ID коллекции из data-атрибута
    const collectionId = this.element.dataset.collectionId;

    // Определяем URL в зависимости от типа (коллекция или избранное)
    const requestUrl =
      collectionId === "favorites"
        ? "/favorites/add_link"
        : `/collection/${collectionId}/add_link`;

    // Отправляем AJAX запрос
    fetch(requestUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: JSON.stringify({
        name: name,
        notes: notes,
        url: linkUrl,
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          // Закрываем модальное окно
          this.close();

          // Очищаем форму
          this.linkNameTarget.value = "";
          this.linkNotesTarget.value = "";
          this.linkUrlTarget.value = "";
          this.addLinkButtonTarget.disabled = true;

          // Перезагружаем страницу, чтобы показать новую ссылку
          window.location.reload();
        } else {
          alert(
            `Ошибка: ${data.error || data.message || "Неизвестная ошибка"}`
          );
        }
      })
      .catch((error) => {
        console.error("Ошибка:", error);
        alert("Произошла ошибка при добавлении ссылки");
      });
  }

  addReference() {
    // Получаем данные из формы
    const title = this.referenceTitleTarget.value.trim();
    const notes = this.referenceNotesTarget.value.trim();
    const fileInput = document.getElementById("file_upload");

    if (!title || !fileInput.files.length) {
      alert("Пожалуйста, заполните название и выберите файл");
      return;
    }

    // Получаем ID коллекции из data-атрибута
    const collectionId = this.element.dataset.collectionId;

    // Определяем URL в зависимости от типа (коллекция или избранное)
    const requestUrl =
      collectionId === "favorites"
        ? "/favorites/add_image"
        : `/collection/${collectionId}/add_image`;

    // Создаем FormData для отправки файла
    const formData = new FormData();
    formData.append("title", title);
    formData.append("notes", notes);
    formData.append("file", fileInput.files[0]);

    // Отправляем AJAX запрос
    fetch(requestUrl, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: formData,
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          // Закрываем модальное окно
          this.close();

          // Очищаем форму
          this.referenceTitleTarget.value = "";
          this.referenceNotesTarget.value = "";
          fileInput.value = "";
          this.fileNameTarget.textContent = "Выбери файл";
          this.addReferenceButtonTarget.disabled = true;

          // Перезагружаем страницу, чтобы показать новый референс
          window.location.reload();
        } else {
          alert(
            `Ошибка: ${data.error || data.message || "Неизвестная ошибка"}`
          );
        }
      })
      .catch((error) => {
        console.error("Ошибка:", error);
        alert("Произошла ошибка при добавлении референса");
      });
  }
}
