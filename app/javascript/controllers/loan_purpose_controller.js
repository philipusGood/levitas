import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="loan-purpose"
export default class extends Controller {
  static targets = ["textInput"];

  connect() {
    this.countLengthOfInputs();
  }

  countLengthOfInputs() {
    this.textInputTargets.forEach((input) => {
      this.countLength(input);
    });
  }

  countLength(input) {
    const id = input.dataset.id;
    if (!id) return;

    const maxLength = input.maxLength || 0;
    const length = input.value.length;

    const countField = document.getElementById(`count_${id}`);
    if (countField) {
      countField.innerHTML = `${length}/${maxLength}`;
    }
  }

  change(e) {
    const input = e.target;
    if (!input) return;

    this.countLength(input);
  }
}
