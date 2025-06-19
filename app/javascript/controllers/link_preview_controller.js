import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "title",
    "url",
    "notes",
    "imageContainer",
    "previewImage",
    "confirmDialog",
    "deleteDialog",
  ];

  connect() {
    console.log("Link preview controller connected");
    this.originalData = {};
    this.hasChanges = false;
    this.currentLinkId = null;
    this.currentCollectionId = null;
  }

  // Основной метод открытия модального окна
  open(title, url, notes, linkId = null, collectionId = null) {
    // Сначала убеждаемся, что все окна закрыты
    this.modalTarget.classList.add("hidden");
    this.confirmDialogTarget.classList.add("hidden");
    this.deleteDialogTarget.classList.add("hidden");

    // Сохраняем оригинальные данные
    this.originalData = {
      title: title || "",
      url: url || "",
      notes: notes || "",
    };

    this.currentLinkId = linkId;
    this.currentCollectionId = collectionId;
    this.hasChanges = false;

    // Заполняем модальное окно
    this.titleTarget.value = this.originalData.title;
    this.urlTarget.value = this.originalData.url;
    this.notesTarget.value = this.originalData.notes;

    // Проверяем, является ли это YouTube ссылкой и показываем превью
    this.showYouTubePreview(url);

    // Показываем модальное окно
    this.modalTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  showYouTubePreview(url) {
    const youtubeRegex = /(?:youtube\.com\/watch\?v=|youtu.be\/)([^\&\?\/]+)/;
    const match = url.match(youtubeRegex);

    if (match && match[1]) {
      const videoId = match[1];
      const previewUrl = `https://img.youtube.com/vi/${videoId}/0.jpg`;

      this.previewImageTarget.src = previewUrl;
      this.imageContainerTarget.classList.remove("hidden");
    } else {
      this.imageContainerTarget.classList.add("hidden");
    }
  }

  // Отслеживание изменений в полях
  trackChanges() {
    const currentData = {
      title: this.titleTarget.value,
      url: this.urlTarget.value,
      notes: this.notesTarget.value,
    };

    this.hasChanges =
      currentData.title !== this.originalData.title ||
      currentData.url !== this.originalData.url ||
      currentData.notes !== this.originalData.notes;
  }

  // Закрытие модального окна с проверкой изменений
  close() {
    if (this.hasChanges) {
      this.showConfirmDialog();
    } else {
      this.forceClose();
    }
  }

  // Принудительное закрытие без проверки
  forceClose() {
    this.modalTarget.classList.add("hidden");
    this.confirmDialogTarget.classList.add("hidden"); // Скрываем диалог подтверждения
    this.deleteDialogTarget.classList.add("hidden"); // Скрываем диалог удаления
    document.body.style.overflow = "auto";
    document.body.style.overflowX = "hidden";
    this.hasChanges = false;
  }

  // Показать диалог подтверждения
  showConfirmDialog() {
    this.modalTarget.classList.add("hidden"); // Скрываем основное окно
    this.confirmDialogTarget.classList.remove("hidden");
  }

  // Закрыть диалог подтверждения
  closeConfirmDialog(event) {
    if (event.target === this.confirmDialogTarget) {
      this.confirmDialogTarget.classList.add("hidden");
      this.modalTarget.classList.remove("hidden"); // Показываем основное окно обратно
    }
  }

  // Отменить изменения и закрыть
  discardChanges() {
    this.confirmDialogTarget.classList.add("hidden");
    this.resetForm();
    this.forceClose();
  }

  // Подтвердить сохранение
  confirmSave() {
    this.confirmDialogTarget.classList.add("hidden");
    this.saveChanges();
  }

  // Сброс формы к оригинальным значениям
  resetForm() {
    this.titleTarget.value = this.originalData.title;
    this.urlTarget.value = this.originalData.url;
    this.notesTarget.value = this.originalData.notes;
    this.hasChanges = false;
  }

  // Сохранение изменений
  saveChanges() {
    if (!this.currentLinkId) {
      alert("Ошибка: ID ссылки не найден");
      return;
    }

    const data = {
      title: this.titleTarget.value,
      path: this.urlTarget.value,
      description: this.notesTarget.value,
    };

    fetch(`/links/${this.currentLinkId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest",
      },
      body: JSON.stringify({ link: data }),
    })
      .then((response) => response.json())
      .then((result) => {
        if (result.success) {
          // Обновляем оригинальные данные
          this.originalData = {
            title: data.title,
            url: data.path,
            notes: data.description,
          };
          this.hasChanges = false;

          // Обновляем превью YouTube если URL изменился
          this.showYouTubePreview(data.path);

          // Показываем уведомление
          // TODO: Можно добавить тост-уведомление о успешном сохранении

          // Перезагружаем страницу чтобы обновить карточку ссылки
          setTimeout(() => window.location.reload(), 500);
        } else {
          alert(`Ошибка при сохранении: ${result.error}`);
        }
      })
      .catch((error) => {
        console.error("Ошибка:", error);
        alert("Произошла ошибка при сохранении изменений");
      });
  }

  // Закрытие модального окна при клике на фон
  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }

  // === МЕТОДЫ ДЛЯ УДАЛЕНИЯ ===

  // Показать диалог подтверждения удаления
  showDeleteDialog() {
    this.modalTarget.classList.add("hidden"); // Скрываем основное окно
    this.deleteDialogTarget.classList.remove("hidden");
  }

  // Закрыть диалог удаления при клике на фон
  closeDeleteDialog(event) {
    if (event.target === this.deleteDialogTarget) {
      this.deleteDialogTarget.classList.add("hidden");
      this.modalTarget.classList.remove("hidden"); // Показываем основное окно обратно
    }
  }

  // Отменить удаление
  cancelDelete() {
    this.deleteDialogTarget.classList.add("hidden");
    this.modalTarget.classList.remove("hidden"); // Показываем основное окно обратно
  }

  // Подтвердить удаление
  confirmDelete() {
    if (!this.currentLinkId) {
      alert("Ошибка: ID ссылки не найден");
      return;
    }

    fetch(`/links/${this.currentLinkId}`, {
      method: "DELETE",
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
        "X-Requested-With": "XMLHttpRequest",
      },
    })
      .then((response) => response.json())
      .then((result) => {
        if (result.success) {
          // Успешное удаление
          this.deleteDialogTarget.classList.add("hidden");
          this.forceClose();

          // Перезагружаем страницу чтобы обновить список ссылок
          setTimeout(() => window.location.reload(), 500);
        } else {
          alert(`Ошибка при удалении: ${result.error}`);
        }
      })
      .catch((error) => {
        console.error("Ошибка:", error);
        alert("Произошла ошибка при удалении ссылки");
      });
  }
}
