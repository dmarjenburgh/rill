bindAddInputButton = ->
  $('#add-input').unbind()
  $('#add-input').bind 'click', (event) ->
    inputType = $('#input-type option:selected').val()
    url = $(event.currentTarget).data('url')
    $.ajax url,
        type: 'POST'
        dataType: 'html'
        data: 'input_type=' + inputType
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{ textStatus }"
        success: (data, textStatus, jqXHR) ->
          $('#inputs-list').append(data)
          bindDeleteInputButtons()
          bindAddAnswerButton()
          bindAddChoiceButton()
          bindCopyToClipboardButton()
          refreshPreview()

bindDeleteInputButtons = ->
  $('.delete-input').unbind()
  $('.delete-input').bind 'click', (event) ->
    if confirm('Are you sure you want to delete this?')
      deleteItem = $(event.currentTarget).data('item')
      url = $(event.currentTarget).data('url')
      $.ajax url,
        type: 'DELETE'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{ textStatus }"
        success: (data, textStatus, jqXHR) ->
          $('#' + deleteItem).remove()
          refreshPreview()

bindAddAnswerButton = ->
  $('.add-answer').unbind()
  $('.add-answer').bind 'click', (event) ->
    url = $(event.currentTarget).data('url')
    $.ajax url,
        type: 'POST'
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{ textStatus }"
        success: (data, textStatus, jqXHR) ->
          inputItem = $(event.currentTarget).data('item')
          list = $('#' + inputItem + ' .answers-list')
          list.append(data)
          bindDeleteAnswerButtons()
          refreshPreview()

bindDeleteAnswerButtons = ->
  $('.delete-answer').unbind()
  $('.delete-answer').bind 'click', (event) ->
    if confirm('Are you sure you want to delete this?')
      deleteItem = $(event.currentTarget).data('item')
      url = $(event.currentTarget).data('url')
      $.ajax url,
        type: 'DELETE'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{ textStatus }"
        success: (data, textStatus, jqXHR) ->
          $('#' + deleteItem).remove()
          refreshPreview()

bindAddChoiceButton = ->
  $('.add-choice').unbind()
  $('.add-choice').bind 'click', (event) ->
    url = $(event.currentTarget).data('url')
    $.ajax url,
        type: 'POST'
        dataType: 'html'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{ textStatus }"
        success: (data, textStatus, jqXHR) ->
          inputItem = $(event.currentTarget).data('item')
          list = $('#' + inputItem + ' .choices-list')
          list.append(data)
          bindCorrectChoiceButtons()
          bindDeleteChoiceButtons()
          refreshPreview()

bindDeleteChoiceButtons = ->
  $('.delete-choice').unbind()
  $('.delete-choice').bind 'click', (event) ->
    if confirm('Are you sure you want to delete this?')
      deleteItem = $(event.currentTarget).data('item')
      url = $(event.currentTarget).data('url')
      $.ajax url,
        type: 'DELETE'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "AJAX Error: #{ textStatus }"
        success: (data, textStatus, jqXHR) ->
          $('#' + deleteItem).remove()
          refreshPreview()

bindSaveButton = ->
  $('.save').unbind()
  $('.save').bind 'click', (event) ->
    save()


bindCorrectChoiceButtons = ->
  $('.toggle_choice').unbind()
  $('.toggle_choice').bind 'click', (event) ->
    input = $(event.currentTarget).data('input')
    $('#input-' + input + ' :checkbox').each (i, element) ->
      if element != $(event.currentTarget)[0]
        $(this).prop("checked",false)

bindCopyToClipboardButton = ->
  new ZeroClipboard($(".copy-button"))

save = ->
  form  = $("#question-form")
  url = form.attr("action")
  $("#edit-time").html('<img src="/spinner.gif" alt="Wait" />')
  sanitizeRichText()
  $.ajax url,
    type: 'PUT'
    dataType: 'json'
    data: form.serialize()
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{ textStatus }"
    success: (data, textStatus, jqXHR) ->
      $("#edit-time").html("Saved on: " + data.updated_at)
      refreshPreview()

updateErrors = ->
  url = $("#error_content").data('url')
  $.ajax url,
    type: 'GET'
    dataType: 'html'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{ textStatus }"
    success: (data, textStatus, jqXHR) ->
      $("#error_content").html(data)

initializeAutoSave = ->
  form = $("#question-form")
  if form.length > 0
    setTimeout(autoSave,10000)

autoSave = ->
  save()
  setTimeout(autoSave,10000)

refreshPreview = ->
  $('#preview_content').attr("src", $('#preview_content').attr("src"))
  height = document.getElementById('preview_content').contentWindow.document.body.scrollHeight
  $('#preview_content').css('height', height)
  updateErrors()

################################################################################

# on load run:
$ ->
  bindAddInputButton()
  bindDeleteInputButtons()
  bindAddAnswerButton()
  bindDeleteAnswerButtons()
  bindAddChoiceButton()
  bindDeleteChoiceButtons()
  bindCorrectChoiceButtons()
  bindCopyToClipboardButton()
  bindSaveButton()
  initializeAutoSave()

################################################################################