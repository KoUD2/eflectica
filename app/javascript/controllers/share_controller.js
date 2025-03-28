import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["vk", "telegram", "link"]

  connect() {
    console.log("Share controller connected")
  }

  shareToVK() {
    const url = window.location.href
    const vkShareUrl = `https://vk.com/share.php?url=${encodeURIComponent(url)}`
    window.open(vkShareUrl, '_blank')
  }

  shareToTelegram() {
    const url = window.location.href
    const tgShareUrl = `https://t.me/share/url?url=${encodeURIComponent(url)}`
    window.open(tgShareUrl, '_blank')
  }

  copyLink() {
    const url = window.location.href
    navigator.clipboard.writeText(url)
      .then(() => {
        this.showTooltip(this.linkTarget)
      })
      .catch(err => {
        console.error('Ошибка при копировании ссылки: ', err)
        this.showTooltip(this.linkTarget, 'Не удалось скопировать ссылку')
      })
  }

  showTooltip(element, message) {
    const tooltip = document.createElement('div')
    tooltip.textContent = message
    tooltip.className = 'tooltip'
    element.appendChild(tooltip)

    setTimeout(() => {
      tooltip.remove()
    }, 2000)
  }
}
