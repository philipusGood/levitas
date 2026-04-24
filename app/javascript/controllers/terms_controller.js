import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['lendersFee', 'interestRate', 'public'];

  connect() {
    if(this.publicTarget.checked) {
      this.setTerms(true);
    }
  }

  togglePublic(event) {
    const isChecked = event.target.checked;

    this.setTerms(isChecked);
  }

  setTerms(isPublic) {
    if(isPublic) {
      this.lendersFeeTarget.value = "";
      this.lendersFeeTarget.placeholder = "To be defined by Levitas";
      this.lendersFeeTarget.disabled = true;

      this.interestRateTarget.value = "";
      this.interestRateTarget.placeholder = "To be defined by Levitas";
      this.interestRateTarget.disabled =  true;
    }
    else {
      this.lendersFeeTarget.value = "0";
      this.lendersFeeTarget.placeholder = "";
      this.lendersFeeTarget.disabled = false;

      this.interestRateTarget.value = "0";
      this.interestRateTarget.placeholder = "";
      this.interestRateTarget.disabled =  false;
    }
  }

}