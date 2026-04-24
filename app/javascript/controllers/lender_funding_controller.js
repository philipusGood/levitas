import { Controller } from "@hotwired/stimulus";

const MIN_INVESTMENT_AMOUNT = 0;
// Connects to data-controller="lender-funding"
export default class extends Controller {
  static targets = ["checkbox", "name", "nameInput", "submit", "amountInput"];

  connect() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true;
    }
  }

  checkAmount() {
    if (this.hasAmountInputTarget && this.hasSubmitTarget) {
      if (parseFloat(this.amountInputTarget.value) >= MIN_INVESTMENT_AMOUNT) {
        this.submitTarget.disabled = false;
      } else {
        this.submitTarget.disabled = true;
      }
    }
  }

  check() {
    if (
      this.hasNameInputTarget &&
      this.hasCheckboxTarget &&
      this.hasNameTarget &&
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
