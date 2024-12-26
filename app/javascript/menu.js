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
