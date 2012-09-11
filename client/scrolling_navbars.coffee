$document = $ document
$(window).on 'scroll', ->
  $articles.jquery.each (i)->
    $e = $ @
    if $e.hasClass 'navbar-fixed-top'
      #if its already floating check the stored data
      if $e.data('original_offset_top') > $document.scrollTop()
        # we need to show it as a toolbar again
        $e.removeClass('navbar-fixed-top')
        # show the previous section as fixed top
        if i > 0
          $($articles.jquery.get(i - 1))
          .show()
    else
      #else check the offset
      if $e.offset().top <= $document.scrollTop()
        # show this section as fixed top
        $e.data('original_offset_top', $e.offset().top)
        $e.addClass('navbar-fixed-top')
        # hide previous section
        $($articles.jquery.get(i - 1)).hide() if i > 0