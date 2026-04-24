# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/components", under: "components"
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js"
pin "dropzone", to: "https://ga.jspm.io/npm:dropzone@6.0.0-beta.2/dist/dropzone.mjs"
pin "just-extend", to: "https://ga.jspm.io/npm:just-extend@5.1.1/index.esm.js"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.8/src/index.js"
pin "@stimulus-components/sortable", to: "https://ga.jspm.io/npm:@stimulus-components/sortable@5.0.1/dist/stimulus-sortable.mjs"
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.2/modular/sortable.esm.js"
pin "@stimulus-components/dropdown", to: "https://ga.jspm.io/npm:@stimulus-components/dropdown@3.0.0/dist/stimulus-dropdown.mjs"
pin "stimulus-use", to: "https://ga.jspm.io/npm:stimulus-use@0.52.2/dist/index.js"
pin "@stimulus-components/clipboard", to: "https://ga.jspm.io/npm:@stimulus-components/clipboard@5.0.0/dist/stimulus-clipboard.mjs"
pin "@rails/activestorage", to: "https://ga.jspm.io/npm:@rails/activestorage@8.0.200/app/assets/javascripts/activestorage.esm.js"
