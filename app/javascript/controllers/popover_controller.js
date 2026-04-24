import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="popover"
export default class extends Controller {
  static targets = ["popover"];

  connect() {}

  toggle(e) {
    const eventSource = e.target.closest(
      "[data-action='click->popover#toggle']",
    );

    if (e.target.nodeName === "A" && eventSource.contains(e.target)) {
      return;
    }

    e.preventDefault();
    e.stopPropagation();

    const id = eventSource && eventSource.dataset.popoverId;
    const target =
      id && this.popoverTargets.find((popover) => popover.id === id);

    if (target) {
      target.classList.toggle("hidden");
    }
  }

  hide(e) {
    for (const popover of this.popoverTargets) {
      if (
        !popover.classList.contains("hidden") &&
        !popover.contains(e.target)
      ) {
        popover.classList.add("hidden");
      }
    }
  }
}
