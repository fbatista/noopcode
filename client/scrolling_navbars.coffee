$document = $ document
$(window).on 'scroll', ->
  $fixed = {}
  $articles.jquery.each (i)->
    $e = $ @
    if $e.parent().offset().top <= $document.scrollTop()
      $fixed.element = $e
  if $fixed.element then $fixed.element.trigger "fixed_top" else $document.trigger "no_fixed_top"

