import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="invite-lenders"
export default class extends Controller {
  static targets = [
    "searchPopup",
    "lendersList",
    "searchForm",
    "inviteForm",
    "addedLenders",
  ];
  static values = {
    email: String,
  };

  connect() {
    if (
      this.hasLendersListTarget &&
      this.lendersListTarget.children.length > 0
    ) {
      document.querySelector("button#send-invites").disabled = false;
    }
  }

  addedLendersTargetConnected(element) {
    if (this.lendersListTarget.children.length > 0) {
      this.updateLendersSelected(this.lendersListTarget.children.length);
      document.querySelector("button#send-invites").disabled = false;
    }
  }

  inviteLenders() {
    this.inviteFormTarget.requestSubmit();
  }

  addLender(e) {
    e.preventDefault();
    const ADD_LENDER_URL = "/deals/invite_lender_add";

    let email = e.target.dataset.lenderEmail;
    let emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (emailRegex.test(email)) {
      fetch(ADD_LENDER_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
          Accept: "text/vnd.turbo-stream.html",
        },
        body: JSON.stringify({ email: email }),
      })
        .then((r) => r.text())
        .then((html) => Turbo.renderStreamMessage(html))
        .then((_) => {
          this.searchPopupTarget.classList.add("hidden");
        });
    }
  }

  /*
  addLender(e) {
    let email = e.target.dataset.lenderEmail;
    let emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (emailRegex.test(email)) {
      const node = this.buildListNode(email);
      if (node) {
        this.lendersListTarget.appendChild(node);
        this.searchPopupTarget.classList.add("hidden");

        if (this.lendersListTarget.children.length > 0) {
          this.updateLendersSelected(this.lendersListTarget.children.length);
          document.querySelector("button#send-invites").disabled = false;
        }
      }
    }
  }
  */

  removeLender(e) {
    const email = e.target.dataset.email;
    if (email) {
      document.getElementById(email).remove();

      this.updateLendersSelected(this.lendersListTarget.children.length);
      if (this.lendersListTarget.children.length <= 0) {
        document.querySelector("button#send-invites").disabled = true;
      }
    }
  }

  updateLendersSelected(count = 0) {
    const SELECTED_LENDERS_TRANSLATE_URL = "/deals/selected_lenders_counter?";
    fetch(
      SELECTED_LENDERS_TRANSLATE_URL +
        new URLSearchParams({
          count: count,
        }),
    )
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  searchLender(e) {
    if (e.target.value !== "" && e.target.value.length < 3) return;

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.searchFormTarget.requestSubmit();
    }, 500);
  }

  buildListNode(email) {
    const exists = document.querySelector(`[data-email='${email}']`);
    if (exists) return;

    const template = document.getElementById("lenderListItemTemplate");

    const result = template.cloneNode(true);
    result.id = email;
    result.querySelector("p").innerText = email;
    result.querySelector("[data-email='']").dataset.email = email;
    result.querySelector("input[type='hidden']").value = email;

    result.classList.remove("hidden");

    return result;
  }
}
