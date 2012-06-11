util   = require "util"
fs     = require "fs"
path   = require "path"
muffin = require "muffin"
glob   = require "glob"
_      = require "underscore"

tmpdir = ".build" #(require "temp").mkdirSync()
basepath = "lib/jumly/build/jumly"
dstpath  = "#{basepath}.js"
minpath  = "#{basepath}.min.js"
version  = fs.readFileSync("lib/jumly/version").toString().trim() #replace /\n/, ""
header   = """
// JUMLY v#{version}, 2011-#{new Date().getFullYear()} copyright(c), all rights reserved.\n
"""

#option "-w", "--watch", "How do I specify argument?"


task "compile", "compile *.coffee", ->
  muffin.run
    files: ["./lib/jumly/js/*.coffee"]
    options: {}
    map:
      "([^/]+).coffee": (matches)->
        src = "lib/jumly/js/#{matches[1]}.coffee"
        dst = "#{tmpdir}/#{matches[1]}.js"
        a = (fs.statSync src).mtime
        b = (fs.statSync dst).mtime if path.existsSync dst
        dirty = a > b or not(a and b)
        muffin.compileScript src, dst, bare:false if dirty


task "concat", "concatenate", ->
  bodies = _.map (glob.sync "#{tmpdir}/*.js"), (e)-> (fs.readFileSync e).toString()
  muffin.writeFile dstpath, [header].concat(bodies).join ""


task "minify", "minify", ->
  muffin.run
    files: [dstpath]
    options: {}
    map:
      ".*": (matches)-> muffin.minifyScript matches[0]
    after: ->
      body = (fs.readFileSync minpath).toString()
      muffin.writeFile minpath, header + body

#task "doc", "", (opts)-> muffin.doccoFile("./lib/jumly/js/core.coffee", opts)

task "test", "print command line to run spec", ->
  console.log "jasmine-node --coffee lib/jumly/js/spec"
