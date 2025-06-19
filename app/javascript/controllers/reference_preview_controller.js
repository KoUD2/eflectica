import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "modal",
    "imagePreview",
    "title",
    "notes",
    "confirmDialog",
    "deleteDialog",
    "currentFileName",
  ];

  connect() {
    this.hasChanges = false;
    this.originalValues = {};
    this.currentImageId = null;
    this.collectionId = null;
    this.selectedFile = null; // Добавляем переменную для хранения выбранного файла
  }

  openModal(event) {
    const imageId = event.currentTarget.dataset.imageId;
    const collectionId = event.currentTarget.dataset.collectionId;

    this.currentImageId = imageId;
    this.collectionId = collectionId;

    // Загружаем данные изображения
    this.loadImageData(imageId);

    this.modalTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  close() {
    if (this.hasChanges) {
      this.showConfirmDialog();
    } else {
      this.forceClose();
    }
  }

  forceClose() {
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

  showConfirmDialog() {
    this.modalTarget.classList.add("hidden");
    this.confirmDialogTarget.classList.remove("hidden");
  }

  closeConfirmDialog(event) {
    if (event.target === this.confirmDialogTarget) {
      this.confirmDialogTarget.classList.add("hidden");
      this.modalTarget.classList.remove("hidden");
    }
  }

  discardChanges() {
    this.confirmDialogTarget.classList.add("hidden");

    // Сброс полей к исходным значениям
    this.titleTarget.value = this.originalValues.title || "";
    this.notesTarget.value = this.originalValues.notes || "";
    if (this.hasCurrentFileNameTarget) {
      this.currentFileNameTarget.value = this.originalValues.fileName || "";
    }

    // Сбрасываем выбранный файл и превью
    this.selectedFile = null;
    if (this.originalValues.imageUrl) {
      this.imagePreviewTarget.src = this.originalValues.imageUrl;
    }

    this.resetChanges();
    this.forceClose();
  }

  confirmSave() {
    this.saveChanges();
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

    fetch(`/images/${this.currentImageId}`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        Accept: "application/json",
      },
    })
      .then((response) => {
        if (response.ok) {
          this.deleteDialogTarget.classList.add("hidden");
          document.body.style.overflowX = "hidden";
          document.body.style.overflowY = "auto";
          location.reload();
        } else {
          console.error("Ошибка при удалении");
          alert("Произошла ошибка при удалении");
        }
      })
      .catch((error) => {
        console.error("Ошибка:", error);
        alert("Произошла ошибка при удалении");
      });
  }

  saveChanges() {
    const csrfToken = document.querySelector('[name="csrf-token"]').content;

    const formData = new FormData();
    formData.append("image[title]", this.titleTarget.value);
    formData.append("image[description]", this.notesTarget.value);

    // Добавляем файл если он был выбран
    if (this.selectedFile) {
      formData.append("image[file]", this.selectedFile);
    }

    fetch(`/images/${this.currentImageId}`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": csrfToken,
        Accept: "application/json",
      },
      body: formData,
    })
      .then((response) => {
        if (response.ok) {
          this.confirmDialogTarget.classList.add("hidden");
          document.body.style.overflowX = "hidden";
          document.body.style.overflowY = "auto";
          location.reload();
        } else {
          console.error("Ошибка при сохранении");
          alert("Произошла ошибка при сохранении");
        }
      })
      .catch((error) => {
        console.error("Ошибка:", error);
        alert("Произошла ошибка при сохранении");
      });
  }

  loadImageData(imageId) {
    fetch(`/images/${imageId}.json`)
      .then((response) => response.json())
      .then((data) => {
        this.titleTarget.value = data.title || "";
        this.notesTarget.value = data.description || "";

        if (data.file_url) {
          this.imagePreviewTarget.src = data.file_url;

          // Извлекаем имя файла из URL и показываем в поле
          if (this.hasCurrentFileNameTarget) {
            const fileName = data.file_url.split("/").pop() || "Текущий файл";
            this.currentFileNameTarget.value = fileName;
          }
        }

        this.originalValues = {
          title: data.title || "",
          notes: data.description || "",
          fileName: data.file_url ? data.file_url.split("/").pop() || "" : "",
          imageUrl: data.file_url || "",
        };

        this.hasChanges = false;
      })
      .catch((error) => {
        console.error("Ошибка загрузки данных:", error);
      });
  }

  selectNewFile() {
    // Создаем временный input для выбора файла
    const fileInput = document.createElement("input");
    fileInput.type = "file";
    fileInput.accept = "image/*";

    fileInput.addEventListener("change", (event) => {
      if (event.target.files.length > 0) {
        const file = event.target.files[0];
        this.selectedFile = file; // Сохраняем файл
        this.currentFileNameTarget.value = file.name;

        // Показываем превью нового изображения
        if (file.type.startsWith("image/")) {
          const reader = new FileReader();
          reader.onload = (e) => {
            this.imagePreviewTarget.src = e.target.result;
          };
          reader.readAsDataURL(file);
        }

        // Вызываем trackChanges чтобы отследить изменение
        this.trackChanges();

        console.log("Выбран новый файл:", file.name);
      }
    });

    fileInput.click();
  }

  resetChanges() {
    this.hasChanges = false;
    this.originalValues = {};
    this.selectedFile = null;
  }
}
