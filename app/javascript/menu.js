document.addEventListener("DOMContentLoaded", function() {
  const links = document.querySelectorAll('.A_IconMenu');
  const sections = document.querySelectorAll('.Q_Section3');
  const search = document.querySelector('.A_IconMenuSearch');

  function hideSections() {
    sections.forEach(section => section.classList.remove('Q_SectionActive'));
  }

  function showSection(targetId) {
    const targetSection = document.getElementById(targetId);
    if (targetSection) {
      targetSection.classList.add('Q_SectionActive');
    } else {
      console.error('Section with id ' + targetId + ' not found!');
    }
  }

  links.forEach(link => {
    link.addEventListener('click', function(e) {
      e.preventDefault();

      links.forEach(link => link.classList.remove('active'));
      links.forEach(link => link.classList.remove('active2'));

      if (link !== search) {
        link.classList.add('active');
      }

      if (link === search) {
        link.classList.add('active2');
      }

      hideSections();

      const targetSectionId = link.getAttribute('data-target');
      showSection(targetSectionId);
    });
  });

  const overlay = document.querySelector('.Q_Overlay');
  const emailField = document.getElementById('email-field');
  const passwordField = document.getElementById('password-field');
  const passwordAgainField = document.getElementById('passwordAgain-field');

  function showOverlay() {
    overlay.style.display = 'block';
  }

  function hideOverlay() {
    overlay.style.display = 'none';
  }

  emailField.addEventListener('click', showOverlay);
  passwordField.addEventListener('click', showOverlay);
  passwordAgainField.addEventListener('click', showOverlay);

  overlay.addEventListener('click', hideOverlay);
});

document.addEventListener("DOMContentLoaded", function() {
  // Получаем все кнопки вкладок и панели контента
  const tabButtons = document.querySelectorAll(".tab-button");
  const tabPanes = document.querySelectorAll(".tab-pane");
  const sectionRegister = document.querySelector(".Q_sectionRegister2");

  // Функция для переключения вкладок
  function switchTab(tabId) {
    // Скрыть все панели контента
    tabPanes.forEach(pane => {
      pane.classList.remove("active2");
    });

    // Убрать активный класс со всех кнопок вкладок
    tabButtons.forEach(button => {
      button.classList.remove("active2");
    });

    // Показать выбранную панель и активировать кнопку вкладки
    document.getElementById(tabId).classList.add("active2");
    document.querySelector(`[data-tab="${tabId}"]`).classList.add("active2");

    // Если нажата вкладка "tab2", убираем класс "disabled123"
    if (tabId === "tab2") {
      sectionRegister.classList.remove("disabled123");
    } else {
      // Восстанавливаем класс "disabled123", если это не вкладка "tab2"
      sectionRegister.classList.add("disabled123");
    }
  }

  // Привязка обработчиков событий для кнопок
  tabButtons.forEach(button => {
    button.addEventListener("click", function() {
      const tabId = button.getAttribute("data-tab");
      switchTab(tabId);
    });
  });

  // Инициализация с первой вкладкой активной
  if (tabButtons.length > 0) {
    switchTab(tabButtons[0].getAttribute("data-tab"));
  }
});
