import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="notifications"
export default class extends Controller {
  static targets = ["confirmDelete", "clearAllBtn"];

  connect() {}

  clearAll(e) {
    e.preventDefault();
    this.toggleClearAll();
    if (this.hasClearAllBtnTarget) {
      this.clearAllBtnTarget.disabled = "disabled";
      this.clearAllBtnTarget.classList.add("disabled");
    }
  }

  toggleClearAll() {
    if (this.hasConfirmDeleteTarget) {
      this.confirmDeleteTarget.classList.toggle("hidden");
      if (
        this.hasClearAllBtnTarget &&
        this.clearAllBtnTarget.hasAttribute("disabled")
      ) {
        this.clearAllBtnTarget.removeAttribute("disabled");
        this.clearAllBtnTarget.classList.remove("disabled");
      }
    }
  }

  deleteNotifications(e) {
    const URL = "/notifications/delete_all";

    fetch(URL, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    }).then((r) => r.text());

    document
      .querySelectorAll(".notification")
      .forEach((notification) => notification.remove());
    this.toggleClearAll();
  }

  markAsRead(e) {
    e.preventDefault();
    if (!e.target.classList.contains("unread")) return;

    const notificationId = e.target.dataset.notificationId;
    if (!notificationId) return;

    const URL = `/notifications/${notificationId}/router`;

    fetch(URL, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    }).then((r) => r.text());

    e.target.classList.remove("unread");
  }

  delete(e) {
    e.preventDefault();
    const notificationNode = e.target.closest(".notification");
    if (notificationNode.classList.contains("deleted")) return;

    const notificationId = e.target.dataset.notificationId;
    if (!notificationId) return;

    const URL = `/notifications/${notificationId}`;

    fetch(URL, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
    }).then((r) => r.text());

    notificationNode.classList.add("deleted");
    notificationNode.remove();
  }
}
