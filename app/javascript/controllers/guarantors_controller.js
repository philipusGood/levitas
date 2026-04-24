import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['confirmation'];

  connect() {
    this.toggle();
  }

  confirmGuarantor() {
    this.toggle();
  }

  toggle() {
    if(this.confirmationTarget.checked) {
      document.querySelector('#guarantor-information').classList.remove('invisible')
    }
    else {
      document.querySelector('#guarantor-information').classList.add('invisible')
    }
  }
}