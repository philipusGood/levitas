import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="deal-terms"
export default class extends Controller {
  static targets = ["checkbox", "name", "nameInput", "submit"];

  connect() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true;
    }
  }

  check() {
    if (
      this.hasNameTarget &&
      this.hasNameInputTarget &&
      this.hasCheckboxTarget &&
      this.hasSubmitTarget
    ) {
      if (
        this.normalize(this.nameTarget.value) === this.normalize(this.nameInputTarget.value) &&
        this.checkboxTarget.checked
      ) {
        this.submitTarget.disabled = false;
      } else {
        this.submitTarget.disabled = true;
      }
    }
  }

  normalize(name) {
    return name.trim().replace(/\s+/g, ' ');
  }
}
