class ErrorsController < ApplicationController
  def not_found
    render '404', status: 404, layout: 'errors'
  end

  def internal_server_error
    render '500', status: 500, layout: 'errors'
  end
end
