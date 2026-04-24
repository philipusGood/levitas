import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    'mortages',
  ]

  connect() {
    this.setOrdinalSuffix();

    this.observer = new MutationObserver(() => {
      this.setOrdinalSuffix()
    });

    this.observer.observe(this.mortagesTarget, {
      attributes: true,
      subtree: true,
      childList: true,
    });
  }

  setOrdinalSuffix() {
    this.mortagesTarget.querySelectorAll('.item .ordinalize').forEach((element, index) => {
      const suffix = this.getOrdinalSuffix(parseInt(index) + 1);
      element.textContent = suffix;
    });
  }

  getOrdinalSuffix(number) {
    const suffixes = ["th", "st", "nd", "rd"];
    const value = parseInt(number) % 100;

    return number + (suffixes[(value - 20) % 10] || suffixes[value] || suffixes[0]);
  }
}
