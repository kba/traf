$("a[data-sample]").on 'click', ->
	sampleName = $(this).attr('data-sample')
	sample = $("##{sampleName}")
	$(".leftPane textarea").val(sample.text().trim())
	$(".leftPane select").val(sample.attr('data-format'))

["leftPane", "rightPane"].forEach (thisPane) ->
	otherPane = if thisPane == 'leftPane' then 'rightPane' else 'leftPane'
	$(".#{thisPane} button").on 'click', ->
		t = new traf()
		t.parseAsync $(".#{thisPane} textarea").val(), {format: $(".#{thisPane} select").val()}, (err, data) ->
			console.log(err)
			t.stringifyAsync data, {format: $(".#{otherPane} select").val()}, (err, str) ->
				console.log(err)
				$(".#{otherPane} textarea").val(str)
