import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["checkbox", "button"];

  connect() {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true;
    }
  }

  close() {
    let modal = document.getElementById("modal");
    if (modal) {
      modal.removeAttribute("src");
      modal.replaceChildren();
    }
  }

  check() {
    if (this.hasCheckboxTarget && this.hasButtonTarget) {
      if (this.checkboxTarget.checked) {
        this.buttonTarget.disabled = false;
      }
      if (!this.checkboxTarget.checked) {
        this.buttonTarget.disabled = true;
      }
    }
  }

  submitEnd(e) {
    if (e.detail.success) {
      this.close();
    }
  }

  reload() {
    window.location.reload();
  }
}
