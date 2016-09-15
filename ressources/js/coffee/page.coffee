$ ->

  $.material.init()

  # init controller
  controller = new ScrollMagic.Controller();

  # create a scene
  new ScrollMagic.Scene({
    duration: 100,    # the scene should last for a scroll distance of 100px
    offset: 0        # start this scene after scrolling for 50px
  })
  .setPin('#banner_image') # pins the element for the the scene's duration
  # .addTo(controller) # assign the scene to the controller

  # create a scene
  new ScrollMagic.Scene({
    triggerElement: $('#banner_logo').get()[0],
    triggerHook: 1,
    duration: "100%"
  })
  .setTween(TweenMax.from($("#banner_logo"), 1, {y: '-40%', autoAlpha: 0.3, ease:Power0.easeNone}))
  # .addTo(controller) # assign the scene to the controller


  # Ascensor js
  window.AileAscensor = $('#ascensor').ascensor({
    ascensorFloorName: ['discover','base','options', 'fare', 'details', 'contact'],
    direction: [[2,2],[1,3],[2,3],[3,3],[2,4],[3,4]],
    ReturnURL:true,
    Time: 500,
    WindowsOn: 1,
    ChildType: 'section',
    Easing: 'easeOutQuad',
    jump: true,
    loop: "increment",
    wheelNavigation: true,
    wheelNavigationDelay: 100,
    ready: ->
      $('#ascensor_menu li a').removeClass('btn-primary')
      $('#ascensor_menu li a[href="'+window.location.hash+'"]').addClass('btn-primary')
      setTimeout(->
        bounce_right()
        update_journey_arrow()
      , 1500)
  })
  window.ascensorInstance = AileAscensor.ascensorInstance = AileAscensor.data('ascensor');

  # Ascensor Event
  AileAscensor.on("scrollStart", (e, floor)->
    $('#ascensor_menu li a').eq(floor.from).removeClass('btn-primary')
    $('#ascensor_menu li a').eq(floor.to).addClass('btn-primary')
  )
  AileAscensor.on("scrollEnd", (e, floor)->
    console.log 'anchor '+ascensorInstance.anchor
    if ascensorInstance.anchor
      window.location = ascensorInstance.anchor
      ascensorInstance.anchor = null
    update_journey_arrow()
  )

  # Ascensor Menu
  menushowed = false

  $('#ascensor_menu li').click (e)->
    e.preventDefault()
    ascensorInstance.scrollToFloor($(this).children().attr('href').substr(1));
    false

  # Ascensor Menu toggle
  toggleout = ->
    if menushowed
      $("#ascensor_menu ul").css({'display': 'none'})
      menushowed = false

  $('#ascensor_menu button').click (e)->
    e.preventDefault()
    $("#ascensor_menu ul").css({'display': 'inline-block'})
    menushowed = true
    false

  $("#ascensor_menu ul").mouseout ->
    toggleout()

  $(document).click ->
    toggleout

  # bounce Ascensor Menu
  bounce_right_animation = new Bounce
  bounce_right_animation.translate({
    from: { x: 0, y: 0 },
    to: { x: 0, y: -($(window).height()/2.1) }
  })

  bounce_right = ->
    console.log 'bounce right'
    $("#ascensor_menu button").fadeIn('fast').delay(50).queue(->
        bounce_right_animation.applyTo($("#ascensor_menu"));
      $("#ascensor_menu ul").delay(600).fadeOut('fast').queue(->
      )
    )

  $('#ascensor a[href="#contact"').click ->
    ascensorInstance.scrollToFloor('contact')

  # Ascensor Journey
  update_journey_arrow = ->
    current = AileAscensor.ascensorInstance.floorActive
    map = AileAscensor.ascensorInstance.options.ascensorFloorName
    $('#page_journey_right').show()
    $('#page_journey_left').show()
    if current is map.length - 1
      $('#page_journey_right').hide()
    if current is 0
      $('#page_journey_left').hide()

  $('.page_journey').click ->
    map = AileAscensor.ascensorInstance.options.ascensorFloorName
    current = AileAscensor.ascensorInstance.floorActive
    way = if $(this).attr('id') is 'page_journey_left' then -1 else 1
    if current + way > map.length - 1 or current + way < 0 then return null
    ascensorInstance.scrollToFloor(map[current + way])

  # Details
  $('div#details div.container div.well button').click ->
    ascensorInstance.scrollToFloor('contact')

  ascensorInstance.anchor = null
  # Options
  $('div#bubbles > div').click ->
    ascensorInstance.scrollToFloor('details')
    ascensorInstance.anchor = '#' + $(this).find('span').first().text()


  # $('div#options > div.container').slick({
  #   swipe: false,
  #   arrows: true,
  #   adaptiveHeight: true,
  #   dots: true,
  #   prevArrow: '<button class="arrow arrow_prev glyphicon glyphicon-chevron-left btn btn-info btn-raised"></button>',
  #   nextArrow: '<button class="arrow arrow_next glyphicon glyphicon-chevron-right btn btn-info btn-raised"></button>',
  # })
  # $('.option_expand').click ->
  #   $parent = $(this).parent()
  #   $arrow = $parent.find('button.option_expand > i').first()
  #   if $arrow.is(':visible')
  #     $parent.removeClass('text_ellipsis')
  #     $parent.children('.dots').hide()
  #     $arrow.hide()
  #     $arrow.next().show()
  #   else
  #     $parent.addClass('text_ellipsis')
  #     $parent.children('.dots').show()
  #     $arrow.show()
  #     $arrow.next().hide()

  # Rotation test

  animate_object_clockwise = (duration, step, amplitude, angle, start_angle, easing, bounces)->
    bounce = new Bounce
    duration = duration ? 800  # ms
    step = step ? 4      # %
    amplitude = amplitude ? 300  # radius
    angle = angle ? 360     # degres
    start_angle = start_angle ? 0
    easing = easing ? 'bounce'
    bounces = bounces ? 2

    prev_x = 0
    prev_y = 0
    angle = angle+start_angle

    for i in [start_angle..angle] by (step*360/100)
      continue if i is angle # 0 == 360
      c = i * (Math.PI / 180)
      tmp_x = Math.round(Math.cos(c)*amplitude)
      tmp_y = Math.round(Math.sin(c)*amplitude)
      x = tmp_x - prev_x
      y = tmp_y - prev_y
      prev_x = tmp_x
      prev_y = tmp_y
      # console.log 'cos '+Math.cos(c)+'    sin '+Math.sin(c)
      # console.log 'angle: '+angle+'  i: '+i+'  cos: ' +x+'  sin: '+y
      console.log 'deg ' + i + '   X: '+x+'('+tmp_x+')'+'   Y:'+y+'('+tmp_y+')'+'   delay: '+((100*i)/(step*angle) * duration)+'  dur:'+duration
      bounce.translate({
        from: { x: 0, y: 0 },
        to: { x: x, y: y },
        delay: (100*i)/(step*angle) * duration,
        duration: duration,
        easing: 'bounce',
        bounces: bounces
      })
    bounce

  params = {dur: 400, step: 2, amp: 200, ang: 360, srt_agl: 0}

  # clock1 = animate_object_clockwise(params.dur, params.step, params.amp, params.ang, 0)
  # clock2 = animate_object_clockwise(params.dur, params.step, params.amp, params.ang, 90)
  # clock3 = animate_object_clockwise(params.dur, params.step, params.amp, params.ang, 180)
  # clock4 = animate_object_clockwise(params.dur, params.step, params.amp, params.ang, 270)
  # animate_object_clockwise(400,16,50,360,0)

  # setTimeout(->
  #   clock1.applyTo($("#test"), { loop: true })
  #   clock2.applyTo($("#test2"), { loop: true })
  #   clock3.applyTo($("#test3"), { loop: true })
  #   clock4.applyTo($("#test4"), { loop: true })
  # , 1500)

  # setTimeout(->
  #   cself.remove()
  # , 4000)
