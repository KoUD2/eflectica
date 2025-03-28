import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileName", "backdrop", "effectLinkSection", "referenceSection"]

  open() {
    this.backdropTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.backdropTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  updateForm(event) {
    const selectedValue = event.target.value

    if (selectedValue === "reference") {
      this.effectLinkSectionTarget.classList.add("hidden")
      this.referenceSectionTarget.classList.remove("hidden")
    } else {
      this.effectLinkSectionTarget.classList.remove("hidden")
      this.referenceSectionTarget.classList.add("hidden")
    }
  }

  updateFileName(event) {
    const files = event.target.files
    if (files.length > 0) {
      this.fileNameTarget.textContent = files[0].name // Обновляем текст на название файла
      this.fileNameTarget.classList.remove("default-color") // Убираем серый цвет
      this.fileNameTarget.classList.add("active-color") // Добавляем черный цвет
    } else {
      this.fileNameTarget.textContent = "Картинка" // Возвращаем текст по умолчанию
      this.fileNameTarget.classList.remove("active-color") // Убираем черный цвет
      this.fileNameTarget.classList.add("default-color") // Возвращаем серый цвет
    }
  }
}
