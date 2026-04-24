import { Controller } from "@hotwired/stimulus";
import Dropzone from "dropzone";

export default class extends Controller {
  static targets = ["form", "loader", "container"];

  connect() {
    this.dropzone = new Dropzone('form.dropzone', {
      disablePreviews: true,
      sending: (file, xhr, formData) => {
        this.loaderTarget.classList.remove('hidden');
        this.containerTarget.classList.add('hidden');
      },
      complete: () => {
        location.reload();
      }
    });
  }

  disconnect() {
    this.dropzone = null;
  }
}