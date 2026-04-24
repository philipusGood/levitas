import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bankruptcyStatusSection", "bankruptcyDetailsSection"];

  connect() {
  }

  toggleBankruptcy(event) {
    const isChecked = event.target.value === "true";

    if (isChecked) {
      this.bankruptcyStatusSectionTarget.classList.remove("hidden");
    } else {
      this.bankruptcyStatusSectionTarget.classList.add("hidden");
    }
  }

  toggleBankruptcyDetails(event) {
    const isChecked = event.target.value === "true";

    if (isChecked) {
      this.bankruptcyDetailsSectionTarget.classList.remove("hidden");
    } else {
      this.bankruptcyDetailsSectionTarget.classList.add("hidden");
    }
  }
}