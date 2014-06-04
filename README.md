GSS to CSS precompiler [![Build Status](https://travis-ci.org/the-gss/gss2css.png?branch=master)](https://travis-ci.org/the-gss/gss2css)
======================

This project provides both a [Node.js](http://nodejs.org/) library and a [Grunt](http://gruntjs.com/) plugin for precompiling constraint-driven [GSS](http://gridstylesheets.org/) layouts to plain CSS.

gss2css utilizes [PhantomJS](http://phantomjs.org/) for rendering the existing GSS layout in various screen sizes and producing the appropriate CSS rules and media queries for those.

## Node.js module

It is possible to run GSS-to-CSS precompilation as a Node.js library in your custom tooling. Example:

```js
// Load the NPM module
var precompiler = require('gss-to-css');

// Sizes configuration
var options = {
  ranges: {
    width: {
      from: 400,
      to: 1000,
      step: 100
    },
    height: 600
  }
};

// Prepare a headless browser for the URL you're interested in
precompiler.open('http://example.net', function (err, page, phantom) {

  // Create a version of the page with GSS converted to CSS media queries
  precompiler.gss2css(page, options, function (err, html) {
    // Serve or save the HTML string

    // Then close down the headless browser
    phantom.exit();
  });

});
```

See the [grunt sizes and ranges documentation](#optionssizes) on the sizing options to provide to the `gss2css` function.

## Grunt plugin

### Getting Started
This plugin requires Grunt `~0.4.1`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install gss-to-css --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('gss-to-css');
```

### The `gss_to_css` task

#### Overview
In your project's Gruntfile, add a section named `gss_to_css` to the data object passed into `grunt.initConfig()`.

```js
grunt.initConfig({
  gss_to_css: {
    options: {
      // Task-specific options go here
    },
    precompile: {
      // Target-specific file lists and/or options go here.
    }
  },
});
```

#### Options

##### options.baseUrl
Type: `String`
Default value: `http://localhost:8002/`

Base URL to use for rendering the GSS-enabled pages. Must be a URL where both the HTML files and their assets, GSS included, are available.

When working with local files the easiest option is to run the `gss_to_css` task together with a local web server provided by [grunt-contrib-connect](https://github.com/gruntjs/grunt-contrib-connect).

##### options.sizes
Type: `Array`
Default value:
```js
[
  {
    width: 1024,
    height: 768
  }
]
```

A list of sizes to render the page in and generate media queries. Useful when the page is targeting a known set of display resolutions, as is often the case when building mobile web apps.

##### options.ranges
Type: `Object`
Default value: `none`

Ranges for width and height to utilize for producing the media queries. Allows compiling GSS into a set of responsive media queries. Overrides `options.sizes` when set.

For example, to generate media queries for each screen size between 400x600 and 1400x600 in 20 pixel intervals, one could configure ranges with:

```js
ranges: {
  width: {
    from: 400,
    to: 1400,
    step: 20
  },
  height: 600
}
```

Note that it is possible to configure ranges for both width and height, in which case all the size combinations will appear in the media queries.

#### Usage examples
In this example we'll build some local GSS-enabled HTML files into the equivalent CSS-powered ones. GSS and other dependencies are available in the local directory structure and the HTTP server is provided via grunt-contrib-connect. The files are stored in the `_site` folder:

```js
grunt.initConfig({
  connect: {
    server: {
      options: {
        port: 8002
      }
    }
  },

  gss_to_css: {
    pages: {
      options: {
        baseUrl: 'http://localhost:8002/',
        sizes: [
          {
            width: 800,
            height: 600
          },
          {
            width: 1024,
            height: 768
          },
          {
            width: 1900,
            height: 1080
          }
        ]
      },
      files: [
        {
          expand: true,
          cwd: '',
          src: ['src/*.html']
          dest: '_site'
        }
      ]
    }
  }
});
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).
