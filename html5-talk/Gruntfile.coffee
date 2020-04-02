#!/usr/bin/env grunt
fs = require('fs')
url = require('url')
path = require 'path'
jade = require 'jade'
connect = require 'connect'
marked = require 'marked'
hljs = require 'highlight.js'

marked.setOptions
  smartypants: true,
  highlight: (lang, code)-> hljs.highlightAuto(lang, code).value

build = (done)->
  jadeOpt =
    pretty: true,
    locals: {}

  process = (filename)->
    opt = Object.create(jadeOpt)
    opt.filename = path.resolve(filename)

    outFilename = filename.replace('.jade', '.html')
    fs.readFile filename, 'utf-8', (err, src)->
      out = jade.compile(src, opt)()
      console.log 'write:', outFilename
      fs.writeFile outFilename, out
      done()

  ['./index.jade'].map process
  return

printPdf = (done)->
  args = [__dirname+'/plugin/print-pdf/print-pdf.js',
     'http://127.0.0.1:8000/index.html?print-pdf',
     'html5-overview.pdf']
  console.log args
  proc = require('child_process').spawn '/usr/local/bin/phantomjs', args
  proc.on 'exit', -> done()


module.exports = (grunt)->
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-livereload'
  grunt.loadNpmTasks 'grunt-regarde'

  grunt.initConfig
    clean: ['index.html']

    regarde:
      content:
        tasks: 'build'
        files: ['index.jade', 'parts/**']
      localserver:
        tasks: 'livereload'
        files: ['index.html']

  grunt.registerTask 'serve:local', ->
    grunt.log.writeln('Serving static content at http://127.0.0.1:8000/')
    connect(connect.static __dirname).listen(8000, '0.0.0.0')

  grunt.registerTask 'build', -> build @async(); return
  grunt.registerTask 'print', -> printPdf @async(); return

  grunt.registerTask 'local', 'build:local'
  grunt.registerTask 'rebuild', ['clean', 'build']

  grunt.registerTask 'serve', ['livereload-start', 'serve:local', 'build', 'regarde']
  grunt.registerTask 'default', 'build'

