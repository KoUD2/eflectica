import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "container", "commentInput"];
  static values = { effectId: String };

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

  handleKeyPress(event) {
    if (event.key === "Enter") {
      event.preventDefault();
      this.submitComment();
    }
  }

  submitComment() {
    const commentBody = this.commentInputTarget.value;
    const ratingValue = parseFloat(this.inputTarget.value);
    const effectId = this.element.dataset.effectId;
    const userId = document.querySelector('input[name="user_id"]').value;

    fetch(`/effects/${effectId}/comments`, {
      method: "POST",
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
            user_id: userId,
          },
        },
      }),
    })
      .then((response) => {
        if (!response.ok) throw new Error("Network error");
        return response.json();
      })
      .then((data) => {
        this.commentInputTarget.value = "";
        this.inputTarget.value = "";
        this.updateStars(0);
        window.location.reload();
      })
      .catch((error) => {
        console.error("Error:", error);
        alert("Ошибка: " + error.message);
      });
  }
}
