import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

export default class extends Controller {
  static targets = [
    "navbar",
    "profile",
    "mainContainer",
    "topBar",
    "navigation",
    "dropdown",
  ];

  initialize() {
    const alerts = document.getElementsByClassName("levitas-alert");
    this.usedSpace = 0;

    for (const alert of alerts) {
      this.usedSpace += alert.offsetHeight;
    }
  }

  connect() {
    flatpickr(".datepicker", {
      enabledTime: true,
    });

    const mobileMenu = document.getElementsByClassName("hamburger-menu") || [];
    let mobileMenuPresent = false;

    if (mobileMenu.length > 0) {
      const hamburgerDisplay = window.getComputedStyle(
        mobileMenu[0].parentElement,
      ).display;

      if (hamburgerDisplay !== "none") {
        mobileMenuPresent = true;
      }
    }
    if (!mobileMenuPresent && this.usedSpace > 0) {
      this.mainContainerTarget.style.height = `calc(100vh - ${this.usedSpace}px)`;
    }

    if (this.hasNavigationTarget && this.usedSpace > 0 && !mobileMenuPresent) {
      this.navigationTarget.style.height = `calc(100vh - ${this.usedSpace}px)`;
    }
  }

  toggleMenu() {
    const alerts = document.getElementsByClassName("levitas-alert");
    this.usedSpace = 0;

    for (const alert of alerts) {
      this.usedSpace += alert.offsetHeight;
    }
    // Changing size of menu container to 100%
    this.navigationTarget.classList.toggle("h-full");
    this.navigationTarget.classList.toggle("gap-6");

    // Updates size of nav element, from 0 to 100%
    this.navbarTarget.classList.toggle("h-0");
    this.navbarTarget.classList.toggle("max-h-0");
    this.navbarTarget.classList.toggle("h-full");

    if (
      this.mainContainerTarget.style &&
      this.mainContainerTarget.style.height
    ) {
      this.mainContainerTarget.style.height = "";
    } else {
      this.mainContainerTarget.style.height = `calc(100dvh - ${this.usedSpace}px)`;
    }

    // Removes shadow from topbar and set hamburger icon as selected
    this.topBarTarget
      .querySelector(".hamburger-menu")
      .classList.toggle("selected");
    this.topBarTarget.classList.toggle("shadow");

    // Overflow hidden on main container, to avoid scrolling over menu size
    this.mainContainerTarget.classList.toggle("truncate");
  }

  toggleDropdown(e) {
    e.preventDefault();
    e.target.closest(".nav-item").classList.toggle("expanded");

    this.dropdownTarget.classList.toggle("hidden");
  }
}
