import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "imagePreview",
    "title",
    "notes",
    "deleteDialog",
    "currentFileName",
  ];

  connect() {
    this.hasChanges = false;
    this.originalValues = {};
    this.currentImageId = null;
    this.selectedFile = null;
  }

  openModal(event) {
    const imageId = event.currentTarget.dataset.imageId;

    this.currentImageId = imageId;

    // Загружаем данные изображения
    this.loadImageData(imageId);

    this.modalTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  close() {
    this.modalTarget.classList.add("hidden");
    document.body.style.overflowX = "hidden";
    document.body.style.overflowY = "auto";
    this.resetChanges();
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }

  trackChanges() {
    const currentTitle = this.titleTarget.value;
    const currentNotes = this.notesTarget.value;
    const currentFileName = this.hasCurrentFileNameTarget
      ? this.currentFileNameTarget.value
      : "";

    this.hasChanges =
      currentTitle !== this.originalValues.title ||
      currentNotes !== this.originalValues.notes ||
      currentFileName !== this.originalValues.fileName;
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

    fetch(`/favorites/remove_image/${this.currentImageId}`, {
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
          document.body.style.overflowX = "hidden";
          document.body.style.overflowY = "auto";
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

  loadImageData(imageId) {
    fetch(`/favorites/show_image/${imageId}`)
      .then((response) => response.json())
      .then((data) => {
        this.titleTarget.value = data.title || "";
        this.notesTarget.value = data.description || "";

        // Сохраняем оригинальные значения
        this.originalValues = {
          title: data.title || "",
          notes: data.description || "",
          fileName: data.image_file_name || "",
        };

        if (data.file_url) {
          this.imagePreviewTarget.src = data.file_url;
        }

        if (this.hasCurrentFileNameTarget && data.image_file_name) {
          this.currentFileNameTarget.value = data.image_file_name;
        }

        this.hasChanges = false;
      })
      .catch((error) => {
        console.error("Ошибка при загрузке данных:", error);
        alert("Произошла ошибка при загрузке данных");
      });
  }

  resetChanges() {
    this.hasChanges = false;
    this.originalValues = {};
    this.selectedFile = null;
  }
}
