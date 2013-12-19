fs = require 'fs'
ent = require 'ent'
clc = require 'cli-color'
{argv} = require 'optimist'
{parseString} = require 'xml2js'

if argv.refresh #for some reason
	fs.readFile './data/whc-en.xml', (err, data) ->
		if err? then throw err
		parseString data, (err, result) ->
			if err? then throw err

			list = result.query.row

			list.forEach (el) ->
				Object.keys(el).forEach((key) ->
					if this[key].length is 1
						this[key] = this[key][0]
				
						if key is "id_number" or key is "date_inscribed" or key is "unique_number" or key is "secondary_dates"
							this[key] = parseInt this[key], 10
						
						if key is "latitude" or key is "longitude"
							this[key] = parseFloat this[key]

						if key is "transboundary"
							this[key] = this[key] is 1
				, el)

			# list.sort (a, b) ->
				# an = a.id_number
				# bn = b.id_number
				# if an > bn then return 1
				# if an < bn then return -1

			obj = {}

			list.forEach (el) ->
				obj[el.id_number] = el

			fs.writeFileSync "./data/list.json", JSON.stringify(obj, null, '\t')
			console.log "Refreshed list.json."

list = JSON.parse(fs.readFileSync("./data/list.json"))

formathtml = (str) ->
	str = ent.decode str
	str = str.replace /(<p>)/g, ''
	str = str.replace /(<\/p>)/g, '\n'
	str = str.replace /(<br.\/>)/g, '\n'
	str = str.replace /<em>([^<]*)<\/em>/g, clc.underline("$&")
	str = str.replace /<string>([^<]*)<\/strong>/g, clc.bold("$&")
	str = str.replace /(<\/?em>)/g, ''
	str = str.replace /(<\/?strong>)/g, ''

display = (site, level=3) ->
	displaystr = """
#{clc.blue clc.bold site.site}
#{clc.green site.location}
#{clc.green site.states} 
#{clc.green site.region} 
#{clc.greenBright site.latitude + ", " + site.longitude}
#{formathtml site.historical_description or site.long_description or site.short_description}
"""
	console.log displaystr

if argv.id
	display list[argv.id]

