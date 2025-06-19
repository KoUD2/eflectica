import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "popup",
    "backdrop",
    "favoriteCheckbox",
    "collectionCheckbox",
  ];

  connect() {
    console.log("Popup controller connected");
  }

  open() {
    console.log("Opening popup");
    this.popupTarget.classList.remove("hidden");
    this.backdropTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  close() {
    console.log("Closing popup");
    this.popupTarget.classList.add("hidden");
    this.backdropTarget.classList.add("hidden");
    document.body.style.overflow = "auto";
    document.body.style.overflowX = "hidden";
  }

  handleFavorite(isChecked, effectId, csrfToken) {
    if (isChecked) {
      fetch("/favorites", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({ effect_id: effectId }),
      })
        .then((response) => {
          if (response.ok) {
            console.log("Effect added to favorites");
          } else {
            console.error("Failed to add effect to favorites");
          }
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    } else {
      fetch(`/favorites/${effectId}`, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrfToken,
        },
      })
        .then((response) => {
          if (response.ok) {
            console.log("Effect removed from favorites");
          } else {
            console.error("Failed to remove effect from favorites");
          }
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    }
  }

  saveCollections() {
    const effectId = this.element.dataset.popupEffectId;
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    // Обрабатываем избранное отдельно
    const favoriteCheckbox = this.favoriteCheckboxTarget;
    if (favoriteCheckbox) {
      this.handleFavorite(favoriteCheckbox.checked, effectId, csrfToken);
    }

    // Получаем текущие коллекции эффекта
    const currentCollections = JSON.parse(
      this.popupTarget.dataset.effectCollections || "[]"
    );

    // Получаем выбранные коллекции (исключаем избранное)
    const selectedCollections = [];
    this.collectionCheckboxTargets.forEach((checkbox) => {
      if (checkbox.checked && checkbox.value !== "favorite") {
        selectedCollections.push(parseInt(checkbox.value));
      }
    });

    console.log("Current collections:", currentCollections);
    console.log("Selected collections:", selectedCollections);

    // Определяем, какие коллекции нужно добавить и удалить
    const collectionsToAdd = selectedCollections.filter(
      (id) => !currentCollections.includes(id)
    );
    const collectionsToRemove = currentCollections.filter(
      (id) => !selectedCollections.includes(id)
    );

    console.log("Collections to add:", collectionsToAdd);
    console.log("Collections to remove:", collectionsToRemove);

    // Создаем массив промисов для всех операций
    const promises = [];

    // Добавляем эффект в новые коллекции
    collectionsToAdd.forEach((collectionId) => {
      console.log(`Adding effect ${effectId} to collection ${collectionId}`);
      const createUrl = "/collection_effects";
      console.log(`POST URL: ${createUrl}`);

      promises.push(
        fetch(createUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": csrfToken,
          },
          body: JSON.stringify({
            collection_id: collectionId,
            effect_id: effectId,
          }),
        })
          .then((response) => {
            console.log(`Create response status: ${response.status}`);
            console.log(`Create response URL: ${response.url}`);
            return response;
          })
          .catch((error) => {
            console.error(
              `Create request failed for collection ${collectionId}:`,
              error
            );
            throw error;
          })
      );
    });

    // Удаляем эффект из коллекций
    collectionsToRemove.forEach((collectionId) => {
      console.log(
        `Removing effect ${effectId} from collection ${collectionId}`
      );
      const deleteUrl = `/remove_effect_from_collection/${collectionId}/${effectId}`;
      console.log(`DELETE URL: ${deleteUrl}`);

      promises.push(
        fetch(deleteUrl, {
          method: "DELETE",
          headers: {
            "X-CSRF-Token": csrfToken,
          },
        })
          .then((response) => {
            console.log(`Delete response status: ${response.status}`);
            console.log(`Delete response URL: ${response.url}`);
            return response;
          })
          .catch((error) => {
            console.error(
              `Delete request failed for collection ${collectionId}:`,
              error
            );
            throw error;
          })
      );
    });

    // Выполняем все операции и закрываем попап после завершения
    Promise.all(promises)
      .then((responses) => {
        // Проверяем, что все запросы прошли успешно
        const allSuccessful = responses.every((response) => response.ok);

        if (allSuccessful) {
          console.log("All collection operations completed successfully");
          // Обновляем данные о текущих коллекциях
          this.popupTarget.dataset.effectCollections =
            JSON.stringify(selectedCollections);
          this.close();
        } else {
          console.error("Some collection operations failed");
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}
