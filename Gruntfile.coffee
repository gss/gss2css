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

    # GSS to CSS precompilation
    gss_to_css:
      fixtures:
        options:
          baseUrl: 'http://localhost:8002/'
          sizes:[
            # Good old displays
            width: 800
            height: 600
          ,
            # iPad landscape
            width: 1010
            height: 660
          ,
            # Larger
            width: 1405
            height: 680
          ]
        files: [
          expand: true
          cwd: ''
          src: ['spec/fixtures/*/original.html']
          rename: (dest, src) -> src.replace 'original', 'grunt'
        ]

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

  @loadTasks 'tasks'
  @loadNpmTasks 'grunt-bower-task'
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-cafe-mocha'

  # Local tasks
  @registerTask 'build', =>
    @task.run 'bower:install'

  @registerTask 'test', =>
    @task.run 'build'
    @task.run 'connect'
    @task.run 'gss_to_css'
    @task.run 'cafemocha'
