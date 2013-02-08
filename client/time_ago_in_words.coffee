Handlebars.registerHelper "time_ago_in_words", (date_string)->
	new Date(date_string).toRelativeTime(50000)