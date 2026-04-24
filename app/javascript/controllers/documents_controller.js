import { Controller } from "@hotwired/stimulus";
import Dropzone from "dropzone";

export default class extends Controller {
  static targets = ["form", "loader", "container"];

  connect() {
    this.dropzone = new Dropzone('form.dropzone', {
      maxFilesize: 10,
      previewTemplate: document.querySelector('#document-preview').innerHTML,
      previewsContainer: "#documents", // Where the previews should be added
      init: function () {
        this.on("success", function (file, response) {
          file.previewElement.remove();
          Turbo.renderStreamMessage(response);
        });
      }
    });
  }

  disconnect() {
    this.dropzone = null;
  }
}