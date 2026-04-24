import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'mortageDetails',
    'mortageContentDetails',
    'hasMortage',
    'propertyType',
    'balanceRemaining',
    'monthlyPayment'
  ]

  handleTypeChange(event) {
    if(event.target.value == 'Real Estate') {
      this.mortageDetailsTarget.classList.remove('hidden');
    }
    else {
      this.mortageDetailsTarget.classList.add('hidden');
      this.mortageContentDetailsTarget.classList.add('hidden');
      this.setDefaultValues();
    }
  }

  handleMortageChange(event) {
    if(event.target.checked) {
      this.mortageContentDetailsTarget.classList.remove('hidden');
    }
    else {
      this.mortageContentDetailsTarget.classList.add('hidden');
      this.setDefaultValues();
    }
  }

  setDefaultValues() {
    this.propertyTypeTarget.value = '';
    this.balanceRemainingTarget.value = '';
    this.monthlyPaymentTarget.value = '';
    this.hasMortageTarget.checked = false;
  }
}