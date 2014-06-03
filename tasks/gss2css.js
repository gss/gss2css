module.exports = function (grunt) {
  var lib = require('../index');
  
  grunt.registerMultiTask('gss_to_css', 'Precompile GSS to CSS in HTML files', function () {
    var done = this.async();
    var options = this.options({
      baseUrl: 'http://localhost:8002/',
      sizes: [
        {
          width: 1024,
          height: 768
        }
      ]
    });

    var todo = this.files.length;
    this.files.forEach(function (f) {
      var sources = f.src.filter(function (source) {
        if (!grunt.file.exists(source)) {
          grunt.log.warn('Source file "' + source + '" not found.');
          return false;
        } 
        return true;
      });
      sources.forEach(function (source) {
        lib.open(options.baseUrl + source, function (err, page, phantom) {
          if (err) {
            grunt.fail.warn(err);
            return;
          }

          var opts = JSON.parse(JSON.stringify(options));
          lib.gss2css(page, opts, function (err, html) {
            if (err) {
              grunt.fail.warn(err);
              return;
            }

            todo--;
            grunt.file.write(f.dest, html);
            grunt.log.writeln('File "' + source + '" precompiled to "' + f.dest + '"');
            if (phantom) {
              phantom.exit();
            }
            if (todo <= 0) {
              done();
            }
          });
        });
      });
    });
  });
};
