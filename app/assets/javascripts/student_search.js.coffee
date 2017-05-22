jQuery.fn.StudentSearch = (config) ->
  element = $(this)
  course_offering_display = config.course_offering_display
  course_offering_id = config.course_offering_id
  notin = config.notin || false

  searchable =
    course_offering:
      id: course_offering_id
      display: course_offering_display

    element: element

    search_students: (callback) ->
      terms = element.find('#terms').val()
      $.ajax
        url: "/course_offerings/#{course_offering_id}/search_students?notin=#{notin}"
        type: 'get'
        data: { terms: terms }
        cache: true
        dataType: 'script'
        success: (data) =>
          if callback
            callback()

    clear_student_search: ->
      element.find('.header').empty()
      element.find('#student').empty()

    init_autocomplete: ->
      that = this
      autocomplete = element.find('#student').autocomplete
        minLength: 2
        autoFocus: true
        source: "/course_offerings/#{course_offering_id}/search_students?notin=#{notin}"
        select: (event, ui) ->
          that.handle_autocomplete_select(event, ui)
          return false

      autocomplete.data('ui-autocomplete')._renderItem = (ul, item) ->
        display = "#{item.first_name} #{item.last_name} (#{item.email})"
        return $('<li class="list-group-item"></li')
          .append(display)
          .appendTo(ul)

    handle_autocomplete_select: (event, ui) ->
      full_name = "#{ui.item.first_name} #{ui.item.last_name}"
      display = if full_name.length > 1 then full_name else ui.item.email
      id = ui.item.id
      element.trigger
        type: 'studentSelect'
        display: display
        id: id

    init: ->
      this.clear_student_search()
      this.init_autocomplete();
      element.find('.header').append "Searching for students from <u>#{course_offering_display}</u>"

  searchable.init()

  return searchable