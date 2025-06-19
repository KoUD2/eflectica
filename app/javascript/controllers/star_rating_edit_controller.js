import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "container", "commentInput"];
  static values = { effectId: String, commentId: String };

  connect() {
    // Устанавливаем текущий рейтинг при подключении
    const currentRating = this.inputTarget.value;
    if (currentRating) {
      this.updateStars(currentRating);
    }
  }

  rate(event) {
    const rating = event.currentTarget.dataset.rating;
    this.inputTarget.value = rating;
    this.updateStars(rating);
  }

  updateStars(rating) {
    this.containerTarget
      .querySelectorAll(".Q_StarIconFeedback")
      .forEach((star, index) => {
        star.classList.toggle("active", index < rating);
      });
  }

  // Удалили обработку Enter - теперь отправка только по кнопке

  submitComment() {
    this.updateComment();
  }

  updateComment() {
    const commentBody = this.commentInputTarget.value;
    const ratingValue = parseFloat(this.inputTarget.value) || 0;
    const effectId = this.element.dataset.effectId;
    const commentId = this.element.dataset.commentId;

    fetch(`/effects/${effectId}/comments/${commentId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        comment: {
          body: commentBody,
          rating_attributes: {
            number: ratingValue,
          },
        },
      }),
    })
      .then((response) => {
        if (!response.ok) throw new Error("Network error");
        return response.json();
      })
      .then((data) => {
        // Перезагружаем страницу после успешного обновления
        window.location.reload();
      })
      .catch((error) => {
        console.error("Error:", error);
        alert("Ошибка при обновлении комментария: " + error.message);
      });
  }
}
