import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["vk", "telegram", "link"];

  connect() {
    console.log("Share controller connected");
  }

  shareToVK() {
    const url = window.location.href;
    const vkShareUrl = `https://vk.com/share.php?url=${encodeURIComponent(
      url
    )}`;
    window.open(vkShareUrl, "_blank");
  }

  shareToTelegram() {
    const url = window.location.href;
    const tgShareUrl = `https://t.me/share/url?url=${encodeURIComponent(url)}`;
    window.open(tgShareUrl, "_blank");
  }

  copyLink() {
    const url = window.location.href;
    navigator.clipboard
      .writeText(url)
      .then(() => {
        this.showTooltip(this.linkTarget, "Ссылка на профиль скопирована!");
      })
      .catch((err) => {
        console.error("Ошибка при копировании ссылки: ", err);
        this.showTooltip(this.linkTarget, "Не удалось скопировать ссылку");
      });
  }

  showTooltip(element, message = "Ссылка скопирована!") {
    const tooltip = document.createElement("div");
    tooltip.textContent = message;
    tooltip.className = "A_tooltip";
    tooltip.style.cssText = `
      position: absolute;
      top: -35px;
      left: 50%;
      transform: translateX(-50%);
      background: #333;
      color: white;
      padding: 8px 12px;
      border-radius: 4px;
      font-size: 14px;
      white-space: nowrap;
      z-index: 1000;
      opacity: 0;
      transition: opacity 0.3s ease;
    `;

    element.style.position = "relative";
    element.appendChild(tooltip);

    // Показываем tooltip
    setTimeout(() => {
      tooltip.style.opacity = "1";
    }, 10);

    // Удаляем tooltip
    setTimeout(() => {
      tooltip.style.opacity = "0";
      setTimeout(() => {
        if (tooltip.parentNode) {
          tooltip.remove();
        }
      }, 300);
    }, 1000);
  }
}
