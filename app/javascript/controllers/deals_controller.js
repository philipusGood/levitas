import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="deals"
export default class extends Controller {
  static targets = [
    "cardView",
    "tableView",
    "cardViewMenu",
    "tableViewMenu",
    "sortMenu",
    "reveal",
    "revealIcon",
    "statusFilterForm",
    "filterValue",
  ];
  static classes = ["selected", "default"];

  switchView(e) {
    if (e.currentTarget.classList.contains(this.selectedClass)) return;
    this.toggleSelected();
    if (e.currentTarget.dataset.dealsTarget === "cardViewMenu") {
      this.displayCardView();
      this.cardViewMenuTarget.classList.remove("hover:cursor-pointer");
      this.tableViewMenuTarget.classList.add("hover:cursor-pointer");
    } else {
      this.displayTableView();
      this.tableViewMenuTarget.classList.remove("hover:cursor-pointer");
      this.cardViewMenuTarget.classList.add("hover:cursor-pointer");
    }
  }

  toggleSelected() {
    this.cardViewMenuTarget.classList.toggle(this.defaultClass);
    this.cardViewMenuTarget.classList.toggle(this.selectedClass);
    this.tableViewMenuTarget.classList.toggle(this.defaultClass);
    this.tableViewMenuTarget.classList.toggle(this.selectedClass);
  }

  showSortOptions(e) {
    e.stopPropagation();
    this.sortMenuTarget.classList.toggle("hidden");
  }

  hideSortOptions() {
    this.sortMenuTarget.classList.add("hidden");
  }

  displayCardView() {
    this.cardViewTarget.classList.remove("hidden");
    this.tableViewTarget.classList.add("hidden");

    this.updateCurrentViewParam("card");
  }

  displayTableView() {
    this.tableViewTarget.classList.remove("hidden");
    this.cardViewTarget.classList.add("hidden");

    this.updateCurrentViewParam("table");
  }

  toggleReveal(e) {
    this.revealTarget.classList.toggle("before:content-none");
    this.revealTarget.classList.toggle("select-none");
    for (const img of this.revealIconTarget.children) {
      img.classList.toggle("hidden");
    }
  }

  updateCurrentViewParam(view = "card") {
    const currentUrl = window.location.href;
    const urlSearchParams = new URLSearchParams(window.location.search);
    urlSearchParams.set("view", view);

    const newUrl = currentUrl.split("?")[0] + "?" + urlSearchParams.toString();
    window.history.replaceState({}, document.title, newUrl);

    document.dispatchEvent(
      new CustomEvent("dealViewChanged", { detail: { value: view } }),
    );
  }

  submitStatusFilter(e) {
    e.preventDefault();

    const actionSearchParams = new URLSearchParams(e.target.href.split("?")[1]);
    const urlSearchParams = new URLSearchParams(window.location.search);

    if (urlSearchParams.has("view"))
      actionSearchParams.set("view", urlSearchParams.get("view"));

    actionSearchParams.set("filter", e.target.dataset.filterValue);

    window.location.href =
      e.target.href.split("?")[0] + "?" + actionSearchParams.toString();
  }

  orderDeals(e) {
    e.preventDefault();
    const ORDER_ATTR = ["sort", "order"];

    const actionSearchParams = new URLSearchParams(e.target.href.split("?")[1]);
    const urlSearchParams = new URLSearchParams(window.location.search);

    for (const [key, value] of urlSearchParams.entries()) {
      if (ORDER_ATTR.includes(key)) continue;
      actionSearchParams.set(key, value);
    }

    window.location.href =
      e.target.href.split("?")[0] + "?" + actionSearchParams.toString();
  }
}
