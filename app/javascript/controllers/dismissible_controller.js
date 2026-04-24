import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["element"];

  dismiss() {
    this.elementTarget.remove();
  }
}