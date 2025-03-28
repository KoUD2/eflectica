import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "submitButton", "nameInput", "usernameInput", "bioInput"]

  connect() {
    this.validateForm()
  }

  upload() {
    this.inputTarget.click()
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewTarget.innerHTML = `
        <img src="${e.target.result}" 
             class="Q_userAvatar" 
             alt="Preview" 
             style="width: 100%; height: 100%; object-fit: cover;">
      `
    }
    reader.readAsDataURL(file)
    this.validateForm()
  }

  validateForm() {
    const isPhotoUploaded = this.hasInputTarget && 
      (this.inputTarget.files.length > 0 || this.previewTarget.querySelector('.Q_userAvatar'));
    
    const isNameFilled = this.hasNameInputTarget && 
      this.nameInputTarget.value.trim() !== '';
    
    const isUsernameFilled = this.hasUsernameInputTarget && 
      this.usernameInputTarget.value.trim() !== '';
    
    const isBioFilled = this.hasBioInputTarget && 
      this.bioInputTarget.value.trim() !== '';
  
    const isValid = isPhotoUploaded && isNameFilled && isUsernameFilled && isBioFilled;
    
    this.submitButtonTarget.disabled = !isValid;
    this.submitButtonTarget.classList.toggle('A_ButtonPrimaryDisabled', !isValid);
  }  
}
