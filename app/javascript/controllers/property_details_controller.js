import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'detailsContainer',
    'toggler',
  ]

  connect() {
  }

  toggle() {
    this.detailsContainerTarget.classList.toggle('hidden');
    if(this.detailsContainerTarget.classList.contains("hidden")) {
      this.togglerTarget.innerHTML = this.togglerTarget.dataset.hidden
    }
    else {
      this.togglerTarget.innerHTML = this.togglerTarget.dataset.display
    }
  }
}
