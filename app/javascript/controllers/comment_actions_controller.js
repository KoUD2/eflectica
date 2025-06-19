import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["editForm"];

  connect() {
    console.log("Comment actions controller connected");
  }

  editComment(event) {
    event.preventDefault();

    // Скрываем секцию с комментарием и кнопками
    const commentArea = this.element.querySelector(".W_CommentArea");
    const commentOptions = this.element.querySelector(".С_CommentOptions");

    // Показываем форму редактирования
    if (this.hasEditFormTarget) {
      this.editFormTarget.classList.remove("hidden");
      commentArea.style.display = "none";
      commentOptions.style.display = "none";
    } else {
      console.error("Edit form target not found");
    }
  }

  cancelEdit(event) {
    event.preventDefault();

    // Показываем секцию с комментарием и кнопками обратно
    const commentArea = this.element.querySelector(".W_CommentArea");
    const commentOptions = this.element.querySelector(".С_CommentOptions");

    // Скрываем форму редактирования
    if (this.hasEditFormTarget) {
      this.editFormTarget.classList.add("hidden");
      commentArea.style.display = "block";
      commentOptions.style.display = "flex";
    }
  }

  deleteComment(event) {
    // Подтверждение удаления уже обрабатывается через Rails confirm
    // Никаких дополнительных действий не требуется
    console.log("Delete comment clicked");
  }
}
