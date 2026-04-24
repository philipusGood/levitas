import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="profile-navigation"
export default class extends Controller {
  static targets = ["link"];

  initialize() {
    const termsSection = document.querySelector("#terms");
    const loanPurposeSection = document.querySelector("#loan_purpose");
    const applicantSection = document.querySelector("#applicant");
    const documentsSection = document.querySelector("#documents");
    const signaturesSection = document.querySelector("#signatures");

    this.scrollingBreakpoints = {
      terms:
        termsSection &&
        termsSection.parentElement &&
        termsSection.parentElement.parentElement
          ? [
              termsSection.parentElement.parentElement.offsetTop,
              termsSection.parentElement.parentElement.offsetTop +
                termsSection.parentElement.parentElement.offsetHeight,
            ]
          : [0, 0],
      loan_purpose:
        loanPurposeSection && loanPurposeSection.parentElement
          ? [
              loanPurposeSection.parentElement.offsetTop,
              loanPurposeSection.parentElement.offsetTop +
                loanPurposeSection.parentElement.offsetHeight,
            ]
          : [0, 0],
      applicant:
        applicantSection && applicantSection.parentElement
          ? [
              applicantSection.parentElement.offsetTop,
              applicantSection.parentElement.offsetTop +
                applicantSection.parentElement.offsetHeight,
            ]
          : [0, 0],
      documents:
        documentsSection && documentsSection.parentElement
          ? [
              documentsSection.parentElement.offsetTop,
              documentsSection.parentElement.offsetTop +
                documentsSection.parentElement.offsetHeight,
            ]
          : [0, 0],
      signatures:
        signaturesSection && signaturesSection.parentElement
          ? [
              signaturesSection.parentElement.offsetTop,
              signaturesSection.parentElement.offsetTop +
                signaturesSection.parentElement.offsetHeight,
            ]
          : [0, 0],
    };

    this.navigationMenuHeight = 64; // height of main site navigation.
    this.dealNavHeight = 58; // height of deal sections navigation.
  }

  connect() {
    const hash = window.location.hash;
    if (hash) {
      const targetAnchor = document.querySelector(`a[href="${hash}"]`);
      if (targetAnchor) {
        this.linkTargets.forEach((el) => {
          el.classList.remove("selected");
        });

        targetAnchor.classList.add("selected");
      }
    }
  }

  highlight(e) {
    this.linkTargets.forEach((el) => {
      el.classList.remove("selected");
    });

    e.currentTarget.classList.add("selected");
  }

  highlightPosition(e) {
    const currPosition =
      window.scrollY > 0
        ? window.scrollY + this.navigationMenuHeight + this.dealNavHeight
        : e.target.scrollTop + this.dealNavHeight;

    for (const section in this.scrollingBreakpoints) {
      const [top, bottom] = this.scrollingBreakpoints[section];
      if (top <= 0 || bottom <= 0) continue;
      if (currPosition >= top && currPosition <= bottom) {
        this.linkTargets.forEach((el) => {
          if (el.href.split("#")[1] === `${section}`) {
            el.classList.add("selected");
          } else {
            el.classList.remove("selected");
          }
        });
      }
    }
  }
}
