fs = require 'fs'
jade = require 'jade'
ASofterClient = require './asofterclient'

ASofterClient.get_all_comic_info (comic_data) ->
# ASofterClient.get_fake_comic_info (comic_data) ->
  fs.readFile 'asofterpage.jade', (err, data) ->
    if err then throw "Erorr reading file."
    page = jade.compile data, pretty: true
    html = page
      comics: comic_data

    fs.writeFile "asofterpage.html", html, (err) ->
      if err then throw "Erorr reading file."
