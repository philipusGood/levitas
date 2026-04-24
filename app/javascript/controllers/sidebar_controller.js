import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["sidebar", "backdrop", "content", "dealView"];

  connect() {
    document.addEventListener("dealViewChanged", (e) => {
      if (this.hasDealViewTarget) {
        this.dealViewTarget.value = e.detail.value;
      }
    });
  }

  toggle() {
    this.sidebarTarget.classList.toggle("translate-x-full");
    this.backdropTarget.classList.toggle("invisible");
    this.backdropTarget.classList.toggle("opacity-0");
    this.backdropTarget.classList.toggle("opacity-40");
  }

  toggleFilterOptions() {
    const URL = "/marketplace/filters_sidebar";
    const queryString = window.location.search;

    fetch(URL + queryString, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));

    this.toggle();
  }

  toggleNotifications() {
    const URL = "/notifications/sidebar";

    this.fetchSidebarPartial(URL).then((_) => this.toggle());
  }

  async fetchSidebarPartial(URL) {
    fetch(URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  toggleDashboardFilters() {
    const URL = "/dashboard/filters_sidebar";
    const queryString = window.location.search;

    fetch(URL + queryString, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));

    this.toggle();
  }
}
