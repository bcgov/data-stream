
# Turbolinks 5
$(document).on 'turbolinks:load', ->
  Redoc.init('public/assets/api.yml', {})
  return

$(document).ready(ready)
$(document).on('page:load', ready)