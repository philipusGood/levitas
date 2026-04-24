import { Controller } from "@hotwired/stimulus";
import Dropzone from "dropzone";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["form", "loader", "container"];
  static values = { dealId: String, formPath: String };

  connect() {
    this.dropzone = new Dropzone('form.dropzone', {
      autoProcessQueue: false,
      maxFilesize: 10,
      previewTemplate: document.querySelector('#document-preview').innerHTML,
      previewsContainer: "#documents",
      
      init: function() {
        this.on("addedfile", (file) => {
          file.previewElement.querySelector('[data-dz-name]').textContent = file.name;
          this.options.uploadFile(file);
        });
      },
      
      uploadFile: this.uploadFile.bind(this)
    });
  }

  async uploadFile(file) {
    const url = "/rails/active_storage/direct_uploads"
    
    const upload = new DirectUpload(file, url, {
      directUploadWillStoreFileWithXHR: (xhr) => {
        xhr.setRequestHeader("X-CSRF-Token", document.querySelector("meta[name='csrf-token']").content);
        xhr.setRequestHeader("Access-Control-Allow-Origin", "*");
      }
    });

    upload.create((error, blob) => {
      if (error) {
        console.error('Direct upload failed:', error);
        file.previewElement.remove();
      } else {
        const hiddenField = document.createElement('input');
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("value", blob.signed_id);
        hiddenField.setAttribute("name", "blob");
        
        this.formTarget.appendChild(hiddenField);
        const formData = new FormData(this.formTarget);
        
        fetch(`${this.formTarget.dataset.documentsAsyncFormPath}`, {
          method: 'POST',
          headers: {
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
            "Accept": "text/vnd.turbo-stream.html"
          },
          body: formData
        })
        .then(response => response.text())
        .then(html => {
          Turbo.renderStreamMessage(html);
          file.previewElement.remove();
        })
        .catch(error => {
          console.error('Upload failed:', error);
          file.previewElement.remove();
        });
        
        hiddenField.remove();
      }
    });
  }

  disconnect() {
    this.dropzone?.destroy();
    this.dropzone = null;
  }
}