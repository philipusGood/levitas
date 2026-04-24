import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "template",
    "items",
    "incomeType",
    "employerAddress",
    "employerContact",
  ];

  connect() {
    this.index = this.itemsTarget.children.length;
  }

  add() {
    const content = this.templateTarget.innerHTML.replace(
      new RegExp("INDEX_TEMPLATE", "g"),
      this.index,
    );
    this.itemsTarget.insertAdjacentHTML("beforeend", content);
    this.index = this.index + 1;

    flatpickr(".datepicker", {
      enabledTime: true,
    });

    if(this.employerAddressTarget) {
      this.employerAddressTarget.classList.remove("hidden");
      this.employerContactTarget.classList.remove("hidden");
    }
  }

  remove(event) {
    const item = event.target.closest(".item");

    if (item) {
      item.remove();
    }
  }

  incomeSelected(e) {
    const employmentIncomeTypes = [
      "Employment Income",
      "Business/Professional Income (Self-employed earnings)",
    ];
    let employmentIncome = false;
    for (const income of this.incomeTypeTargets) {
      if (employmentIncomeTypes.includes(income.value)) {
        employmentIncome = true;
        break;
      }
    }

    if (!employmentIncome) {
      this.employerAddressTarget.classList.add("hidden");
      this.employerContactTarget.classList.add("hidden");
    } else {
      this.employerAddressTarget.classList.remove("hidden");
      this.employerContactTarget.classList.remove("hidden");
    }
  }

  hideEmployerFields() {}
}
