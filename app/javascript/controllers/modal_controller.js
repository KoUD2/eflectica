// app/javascript/controllers/modal_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "content", "step1", "step2", "step3"];

  connect() {
    this.step = 1; // Начальный шаг
  }

  open() {
    this.modalTarget.classList.remove("hidden");
  }

  next() {
    this.step += 1;

    if (this.step === 2) {
      this.updateContent(
        "Программы",
        "Будем преимущественно показывать эффекты с этими программами",
        ["Lightroom", "Photoshop", "Capture One", "Affinity Photo", "Blender","Maya", "Cinema 4D", "ZBrush", "3ds Max"]
      );
      this.highlightStep(this.step);
    } else if (this.step === 3) {
      this.updateContentStep3();
      this.highlightStep(this.step);
    }
  }

  updateContentStep3() {
    this.contentTarget.innerHTML = `
      <h2 class='A_Header2'>Подписки</h2>
      <p class='A_TextEffectDescription A_TextEffectDescriptionSettingsFeedFinal'>
        В ленте автоматически появятся эффекты из подписок. Ты можешь перейти в раздел коллекций сейчас или найти подписки позже.
      </p>
      <div class="A_More">
        <a href="/news_feeds" class="A_LinkPrimary" class="A_TextButtonPrimary">Перейти к подпискам</a>
        <img src="/assets/ArrowIcon.svg" alt="ArrowIcon.svg" class="Q_arrowFollow"  
      </div>
    `;
  
    const button = document.querySelector(".A_ButtonPrimaryClose");
    button.textContent = "Завершить настройку";
    button.setAttribute("data-action", "modal#close");
  }
  

  updateContent(header, description, items) {
    this.contentTarget.innerHTML = `
      <h2 class='A_Header2'>${header}</h2>
      <p class='A_TextEffectDescription A_TextEffectDescriptionSettingsFeed'>${description}</p>
      <ul class="C_Choice C_ChoiceFeed">
        ${items.map(item => {
          const iconName = item.toLowerCase().replace(/ /g, "_");
          return `
            <li class="M_Choice">
              <label class="custom-checkbox">
                <div class="W_nameImg">
                  <img src="/assets/${iconName}_icon.svg" alt="${iconName}" class="Q_ProgramIconFeed" />
                  <p class="A_TextButtonSeсondary A_TextButtonSeсondaryBlack">
                    ${item}
                  </p>
                </div>
                <input type="checkbox" name="collection" value="${item}" />
                <span class="checkmark"></span>
              </label>
            </li>`;
        }).join("")}
        <li class="M_Choice">
          <label class="custom-checkbox">
            <p class="A_TextButtonSeсondary A_TextButtonSeсondaryBlack">
              Отметить все
            </p>
            <input type="checkbox" name="collection" value="all" />
            <span class="checkmark"></span>
          </label>
        </li>
      </ul>`;
  }

  highlightStep(step) {
    this.step1Target.classList.remove("A_TextTagFeedActive");
    this.step2Target.classList.remove("A_TextTagFeedActive");
    this.step3Target.classList.remove("A_TextTagFeedActive");

    if (step === 1) {
      this.step1Target.classList.add("A_TextTagFeedActive");
    } else if (step === 2) {
      this.step2Target.classList.add("A_TextTagFeedActive");
    } else if (step === 3) {
      this.step3Target.classList.add("A_TextTagFeedActive");
    }
  }

  close() {
    this.modalTarget.classList.add("hidden");

    const feedSettings = document.querySelector('.M_feedSettings');
    if (feedSettings) {
      feedSettings.style.display = 'none';
    }

    const feedsMain = document.querySelector('.W_feedsMain');
    if (feedsMain) {
      feedsMain.style.display = 'flex';
    }
  }
}
