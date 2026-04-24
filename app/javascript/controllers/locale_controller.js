import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="locale"
export default class extends Controller {
  static targets = [
    "languageOptions",
    "languageOptionsMobile",
    "chevronRight",
    "chevronDown",
  ];
  static mobileHidden;

  connect() {
    this.mobileHidden = true;
  }

  showOptions() {
    if (!this.hasLanguageOptionsTarget) return;

    this.languageOptionsTarget.classList.toggle("hidden");
    this.languageOptionsTarget.classList.toggle("max-md:hidden");
  }

  toggleMobileOptions() {
    if (window.innerWidth >= 933) return; // Iphone 14 pro max landscape resolution width
    if (!this.hasLanguageOptionsMobileTarget) return;

    if (this.mobileHidden) {
      this.showMobileOptions();
    } else {
      this.hideMobileOptions();
    }
  }

  showMobileOptions() {
    this.languageOptionsMobileTarget.classList.remove("invisible");
    this.languageOptionsMobileTarget.classList.remove("h-0");
    this.languageOptionsMobileTarget.classList.add("h-24");

    for (let el of this.languageOptionsMobileTarget.children) {
      el.classList.remove("hidden");
    }

    this.chevronRightTarget.classList.toggle("hidden");
    this.chevronDownTarget.classList.toggle("hidden");

    this.mobileHidden = false;
  }

  hideMobileOptions() {
    for (let el of this.languageOptionsMobileTarget.children) {
      el.classList.add("hidden");
    }

    this.languageOptionsMobileTarget.classList.add("invisible");
    this.languageOptionsMobileTarget.classList.remove("h-24");
    this.languageOptionsMobileTarget.classList.add("h-0");

    this.chevronRightTarget.classList.toggle("hidden");
    this.chevronDownTarget.classList.toggle("hidden");

    this.mobileHidden = true;
  }
}
