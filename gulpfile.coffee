gulp = require 'gulp'
plumber = require 'gulp-plumber'
change = require 'gulp-change'
rename = require 'gulp-rename'
coffeelint = require 'gulp-coffeelint'
coffee = require 'coffee-script'

gulp.task 'build-grammars', ->
  gulp.src 'src/grammars/*.coffee'
      .pipe plumber (error) ->
        console.log error.toString()
        @emit('end')
      .pipe coffeelint()
      .pipe coffeelint.reporter()
      .pipe coffeelint.reporter('fail')
      .pipe change (code) -> JSON.stringify coffee.eval(code, filename: @file.path)
      .pipe rename extname: '.json'
      .pipe gulp.dest './grammars'

gulp.task 'watch-grammars', ->
  gulp.watch 'src/grammars/*.coffee', ['build-grammars']

gulp.task 'watch', ['watch-grammars']
gulp.task 'build', ['build-grammars']
gulp.task 'default', ['build']
