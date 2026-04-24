import { Application } from "@hotwired/stimulus"
import Dropdown from '@stimulus-components/dropdown'
import Clipboard from '@stimulus-components/clipboard'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

application.register('dropdown', Dropdown)
application.register('clipboard', Clipboard)

export { application }
