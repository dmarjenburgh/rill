# updateCounter = (star) ->
#   nr_of_subsections = $('.subsection-panel.star-' + star).length
#   $('#badge_' + star).html(nr_of_subsections)
#
# bindAddButtons = ->
#   $('.add-subsection').unbind()
#   $('.add-subsection').bind 'click', (event) ->
#     star = $(event.currentTarget).data('star')
#     after = $(event.currentTarget).data('after')
#     url = $(event.currentTarget).data('url')
#     $.ajax url,
#         type: 'POST'
#         dataType: 'html'
#         error: (jqXHR, textStatus, errorThrown) ->
#           console.log "AJAX Error: #{ textStatus }"
#         success: (data, textStatus, jqXHR) ->
#           $('#' + after).after(data)
#           bindAddButtons()
#           bindDeleteButtons()
#           updateCounter(star)
#           refreshPreview(star)
#
# bindDeleteButtons = ->
#   $('.delete-subsection').unbind()
#   $('.delete-subsection').bind 'click', (event) ->
#     # if confirm('Are you sure you want to delete this?')
#     deleteItem = $(event.currentTarget).data('item')
#     star = $(event.currentTarget).data('star')
#     url = $(event.currentTarget).data('url')
#     $.ajax url,
#         type: 'DELETE'
#         dataType: 'json'
#         error: (jqXHR, textStatus, errorThrown) ->
#           console.log "AJAX Error: #{ textStatus }"
#         success: (data, textStatus, jqXHR) ->
#           $('#' + deleteItem).remove()
#           updateCounter(star)
#           refreshPreview(star)
#
# bindSaveButton = ->
#   $('.save').unbind()
#   $('.save').bind 'click', (event) ->
#     save()
#
# save = ->
#   form  = $("#section-form")
#   url = form.context.URL
#   $("#edit-time").html('<img src="/assets/spinner.gif" alt="Wait" />')
#   $.ajax url,
#     type: 'POST'
#     dataType: 'json'
#     data: form.serialize()
#     error: (jqXHR, textStatus, errorThrown) ->
#       console.log "AJAX Error: #{ textStatus }"
#     success: (data, textStatus, jqXHR) ->
#       $("#edit-time").html(data.updated_at)
#       refreshAllPreviews()
#
# refreshAllPreviews = ->
#   refreshPreview(1)
#   refreshPreview(2)
#   refreshPreview(3)
#
# refreshPreview = (star) ->
#   $('#preview-' + star).attr("src", $('#preview-' + star).attr("src"))
#   height = document.getElementById('preview-' + star).contentWindow.document.body.scrollHeight
#   $('#preview-' + star).css('height', height)
#
# ################################################################################
#
# # on load run:
# $ ->
#   bindAddButtons()
#   bindDeleteButtons()
#   bindSaveButton()
#   setTimeout(save,100)
#   setInterval(save,10000)
#
# ################################################################################
