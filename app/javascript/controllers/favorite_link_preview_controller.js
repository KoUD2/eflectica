import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "title",
    "url",
    "notes",
    "imageContainer",
    "previewImage",
    "deleteDialog",
  ];

  connect() {
    console.log("Favorite link preview controller connected");
    this.originalData = {};
    this.hasChanges = false;
    this.currentLinkId = null;
  }

  // Основной метод открытия модального окна
  open(title, url, notes, linkId = null) {
    // Сначала убеждаемся, что все окна закрыты
    this.modalTarget.classList.add("hidden");
    this.deleteDialogTarget.classList.add("hidden");

    // Сохраняем оригинальные данные
    this.originalData = {
      title: title || "",
      url: url || "",
      notes: notes || "",
    };

    this.currentLinkId = linkId;
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

  close() {
    this.modalTarget.classList.add("hidden");
    document.body.style.overflow = "auto";
  }

  showYouTubePreview(url) {
    const youtubeRegex = /(?:youtube\.com\/watch\?v=|youtu\.be\/)([^\&\?\/]+)/;
    const match = url.match(youtubeRegex);

    if (match && match[1]) {
      const videoId = match[1];
      const thumbnailUrl = `https://img.youtube.com/vi/${videoId}/0.jpg`;

      this.previewImageTarget.src = thumbnailUrl;
      this.imageContainerTarget.classList.remove("hidden");
    } else {
      this.imageContainerTarget.classList.add("hidden");
    }
  }

  trackChanges() {
    const currentTitle = this.titleTarget.value;
    const currentUrl = this.urlTarget.value;
    const currentNotes = this.notesTarget.value;

    this.hasChanges =
      currentTitle !== this.originalData.title ||
      currentUrl !== this.originalData.url ||
      currentNotes !== this.originalData.notes;
  }

  showDeleteDialog() {
    this.modalTarget.classList.add("hidden");
    this.deleteDialogTarget.classList.remove("hidden");
  }

  closeDeleteDialog(event) {
    if (event.target === this.deleteDialogTarget) {
      this.deleteDialogTarget.classList.add("hidden");
      this.modalTarget.classList.remove("hidden");
    }
  }

  cancelDelete() {
    this.deleteDialogTarget.classList.add("hidden");
    this.modalTarget.classList.remove("hidden");
  }

  confirmDelete() {
    const csrfToken = document.querySelector('[name="csrf-token"]').content;

    fetch(`/favorites/remove_link/${this.currentLinkId}`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        Accept: "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          this.deleteDialogTarget.classList.add("hidden");
          document.body.style.overflow = "auto";
          location.reload();
        } else {
          console.error("Ошибка при удалении:", data.error);
          alert(`Ошибка при удалении: ${data.error}`);
        }
      })
      .catch((error) => {
        console.error("Ошибка:", error);
        alert("Произошла ошибка при удалении");
      });
  }

  // Закрытие модального окна при клике на фон
  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }
}
