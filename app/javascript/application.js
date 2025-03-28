// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import Rails from "@rails/ujs"
import "controllers"
import "menu"
Rails.start();

document.addEventListener("DOMContentLoaded", () => {
  const loginForm = document.getElementsByClassName("login-form")[0];
  const registrationForm = document.getElementsByClassName("registration-form")[0];

  document.getElementById("show-registration-form").addEventListener("click", (e) => {
    e.preventDefault();
    loginForm.classList.add("hidden");
    registrationForm.classList.remove("hidden");
  });

  document.getElementById("show-login-form").addEventListener("click", (e) => {
    e.preventDefault();
    registrationForm.classList.add("hidden");
    loginForm.classList.remove("hidden");
  });
});
