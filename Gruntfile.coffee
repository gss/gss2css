module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # GSS installation
    bower:
      install:
        options:
          copy: false

    # Local web server for testing purposes
    connect:
      server:
        options:
          port: 8002

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

  @loadNpmTasks 'grunt-bower-task'
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-cafe-mocha'

  # Local tasks
  @registerTask 'build', =>
    @task.run 'bower:install'

  @registerTask 'test', =>
    @task.run 'build'
    @task.run 'connect'
    @task.run 'cafemocha'
