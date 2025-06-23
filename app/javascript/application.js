// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import Rails from "@rails/ujs";
import "controllers";
import "menu";
Rails.start();

function initializeAuthForms() {
  const loginForm = document.getElementsByClassName("login-form")[0];
  const registrationForm =
    document.getElementsByClassName("registration-form")[0];
  const showRegistrationBtn = document.getElementById("show-registration-form");
  const showLoginBtn = document.getElementById("show-login-form");

  if (
    showRegistrationBtn &&
    !showRegistrationBtn.hasAttribute("data-listener-added")
  ) {
    showRegistrationBtn.addEventListener("click", (e) => {
      e.preventDefault();
      if (loginForm && registrationForm) {
        loginForm.classList.add("hidden");
        registrationForm.classList.remove("hidden");
      }
    });
    showRegistrationBtn.setAttribute("data-listener-added", "true");
  }

  if (showLoginBtn && !showLoginBtn.hasAttribute("data-listener-added")) {
    showLoginBtn.addEventListener("click", (e) => {
      e.preventDefault();
      if (loginForm && registrationForm) {
        registrationForm.classList.add("hidden");
        loginForm.classList.remove("hidden");
      }
    });
    showLoginBtn.setAttribute("data-listener-added", "true");
  }
}

document.addEventListener("DOMContentLoaded", initializeAuthForms);
document.addEventListener("turbo:load", initializeAuthForms);

// Функции для работы с GIF изображениями
window.GifImageHelper = {
  // Проверяет, является ли URL GIF файлом
  isGifUrl: function (url) {
    return url && url.toLowerCase().includes(".gif");
  },

  // Настраивает GIF изображение с анимацией при наведении
  setupGifImage: function (imgElement, gifUrl) {
    if (!this.isGifUrl(gifUrl)) return;

    // Создаем canvas для получения статичного кадра
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    const tempImg = new Image();

    tempImg.crossOrigin = "anonymous";
    tempImg.onload = () => {
      canvas.width = tempImg.width;
      canvas.height = tempImg.height;
      ctx.drawImage(tempImg, 0, 0);

      const staticUrl = canvas.toDataURL();

      // Устанавливаем статичное изображение по умолчанию
      imgElement.src = staticUrl;
      imgElement.dataset.gifUrl = gifUrl;
      imgElement.dataset.staticUrl = staticUrl;
      imgElement.dataset.isGif = "true";
      imgElement.style.cursor = "pointer";

      // Добавляем обработчики наведения
      this.addHoverHandlers(imgElement);
    };

    tempImg.onerror = () => {
      // Если не удалось загрузить для получения статичного кадра,
      // просто используем оригинальный GIF
      imgElement.dataset.gifUrl = gifUrl;
      imgElement.dataset.staticUrl = gifUrl;
      imgElement.dataset.isGif = "true";
      imgElement.style.cursor = "pointer";
      this.addHoverHandlers(imgElement);
    };

    tempImg.src = gifUrl;
  },

  // Добавляет обработчики наведения мыши
  addHoverHandlers: function (imgElement) {
    // Удаляем старые обработчики если есть
    imgElement.removeEventListener("mouseenter", imgElement._gifMouseEnter);
    imgElement.removeEventListener("mouseleave", imgElement._gifMouseLeave);

    // Создаем новые обработчики
    imgElement._gifMouseEnter = () => {
      if (imgElement.dataset.isGif === "true") {
        imgElement.src = imgElement.dataset.gifUrl;
      }
    };

    imgElement._gifMouseLeave = () => {
      if (imgElement.dataset.isGif === "true") {
        imgElement.src = imgElement.dataset.staticUrl;
      }
    };

    // Добавляем обработчики
    imgElement.addEventListener("mouseenter", imgElement._gifMouseEnter);
    imgElement.addEventListener("mouseleave", imgElement._gifMouseLeave);
  },

  // Инициализирует все GIF изображения на странице
  initializeAllGifs: function () {
    const images = document.querySelectorAll(
      "img.A_PhotoEffect, img.Q_emptyImage"
    );
    images.forEach((img) => {
      if (this.isGifUrl(img.src)) {
        this.setupGifImage(img, img.src);
      }
    });
  },
};

// Автоматически инициализируем GIF изображения при загрузке страницы
document.addEventListener("DOMContentLoaded", function () {
  window.GifImageHelper.initializeAllGifs();
});

// Инициализируем GIF изображения после Turbo навигации
document.addEventListener("turbo:load", function () {
  window.GifImageHelper.initializeAllGifs();
});
