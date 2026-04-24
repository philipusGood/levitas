import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="edit-deal-sidebar"
export default class extends Controller {
  static targets = ["menuItem", "section"];

  connect() {
    const hasError = document.querySelector(".bg-red-50");
    if (hasError) {
      hasError.scrollIntoView({ behavior: "smooth" });
    }
    this.selectedSection = document.querySelector(
      ".step a.active, .step-nested .substeps a.active",
    );
    this.observeSections();
  }

  observeSections() {
    this.sectionTargets.forEach((section) => {
      const observerOptions = this.getObserverOptionsForSection(section);
      const observer = new IntersectionObserver(
        this.handleIntersect.bind(this),
        observerOptions,
      );
      observer.observe(section);
    });
  }

  getObserverOptionsForSection(section) {
    if (
      [
        "property",
        "main_applicant_income",
        "secondary_applicant_income",
      ].includes(section.id)
    ) {
      return {
        root: null,
        rootMargin: "0px",
        threshold: 0.4,
      };
    } else {
      return {
        root: null,
        rootMargin: "0px",
        threshold: 0.8,
      };
    }
  }

  handleIntersect(entries) {
    entries.forEach((entry) => {
      const menuItem = this.menuItemTargets.find(
        (item) =>
          item.getAttribute("data-edit-deal-sidebar-id") === entry.target.id,
      );

      if (entry.isIntersecting) {
        this.activateMenuItem(menuItem);
      }
    });
  }

  activateMenuItem(menuItem) {
    if (!menuItem) return;
    this.menuItemTargets.forEach((item) => item.classList.remove("active"));
    if (menuItem.closest(".step-nested")) {
      menuItem.closest(".step-nested").classList.add("expanded");
    }
    menuItem.classList.add("active");
  }

  select(event) {
    const selectedItem = event.currentTarget;
    if (this.selectedSection && this.selectedSection !== selectedItem) {
      this.selectedSection.classList.remove("active");
      if (this.selectedSection.classList.contains("step-nested")) {
        this.collapseMenu(this.selectedSection);
      } else if (this.selectedSection.closest(".step-nested")) {
        this.collapseMenu(this.selectedSection.closest(".step-nested"));
      }
    }

    this.selectedSection = selectedItem;
    if (!this.selectedSection.classList.contains("step-nested")) {
      this.selectedSection.classList.add("active");
    } else {
      this.expandMenu(this.selectedSection);
    }
  }

  collapseMenu(menu) {
    menu.querySelector(".substeps").classList.add("hidden");
    menu.classList.remove("expanded");
  }

  expandMenu(menu) {
    menu.classList.add("expanded");
    menu.querySelector(".substeps").classList.remove("hidden");
    if (menu.querySelector(".substeps a.active") === null) {
      menu.querySelector(".substeps a").click();
    }
  }

  disconnect() {
    this.observer.disconnect();
  }
}
