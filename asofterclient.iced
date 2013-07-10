_U = require 'underscore'
request = require 'request'
cheerio = require 'cheerio'

module.exports = ASofterClient =
  get_archive: (cb) ->
    # calls cb on e.g. {
    #   comics: [
    #     url: 'http://www.asofterworld.com/index.php?id=157'
    #     title: 'nobody gonna wesley snipe me'
    #     num: '157'
    #   ]
    # }

    url = "http://www.asofterworld.com/archive.php"

    request url, (err, resp, body) ->
      $ = cheerio.load(body)
      archive_page_data =
        comics: $('font[size=-1] a').map (i, el) ->
          url: $(el).attr 'href'
          title: $(el).text()
          num: (/(\d+): /.exec $(el).parent().text())[1]

      cb? archive_page_data

  get_comic_by_url: (url, cb) ->
    # `url` e.g. "http://www.asofterworld.com/index.php?id=988"
    # call c.b. on e.g. {
    #   img_src: 'http://www.asofterworld.com/clean/teahill.jpg'
    #   hover_text: 'I miss city life'
    # }

    request url, (err, resp, body) ->
      $ = cheerio.load(body)
      comic_page_data =
        img_src: $('#thecomic img').attr 'src'
        hover_text: $('#thecomic img').attr 'title'

      cb? comic_page_data

  get_all_comic_info: (cb) ->
    # calls cb on an array
    # which is a combination of get_comic_by_url
    # and get_archive.
    # properties are
    #   `url`
    #   `title`
    #   `num`
    #   `img_src`
    #   `hover_text`
    ASofterClient.get_archive ({comics}) ->
      extended_datas = []
      await
        _U.map comics, (comic, i) ->
          f = (cb) -> ASofterClient.get_comic_by_url comic.url, (data) ->
            cb _U.extend {}, comic, data
          f defer extended_datas[i]

      cb? extended_datas

  get_fake_comic_info: (cb) ->
    cb? [
      url: 'http://www.asofterworld.com/index.php?id=987'
      title: 'but i will put anything in my mouth that is given to me.'
      num: '987'
      img_src: 'http://www.asofterworld.com/clean/stakeout.jpg'
      hover_text: 'but i will put anything in my mouth that is given to me.'
    ,
      url: 'http://www.asofterworld.com/index.php?id=988'
      title: 'What\'s good for the goose.'
      num: '988'
      img_src: 'http://www.asofterworld.com/clean/cove.jpg'
      hover_text: 'What\'s good for the goose.'
    ]


if require.main is module
  # ASofterClient.get_archive ({comics}) ->
  #   console.log comics

  # url = "http://www.asofterworld.com/index.php?id=988"
  # ASofterClient.get_comic_by_url url, (data) ->
  #   console.log data

  ASofterClient.get_all_comic_info (comic_data) ->
    console.log comic_data
