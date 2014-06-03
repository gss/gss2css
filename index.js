var phantom = require('node-phantom-ws');
var jsdom = require('jsdom');
exports.open = function (url, options, callback) {
  if (!callback) {
    callback = options;
    options = {};
  }
  if (!options.width) {
    options.width = 800;
  }
  if (!options.height) {
    options.height = 600;
  }
  phantom.create(function (err, ph) {
    if (err) {
      return callback(err);
    }
    ph.createPage(function (err,page) {
      if (err) {
        return callback(err);
      }
      page.set('viewportSize', {
        width: options.width,
        height: options.height
      }, function (err) {
        page.onError = function (msg, trace) {
          console.log(msg);
        };

        var checkReady = function () {
          page.evaluate(function () {
            return GSS.isDisplayed;
          }, function (err, res) {
            if (res) {
              return callback(null, page);
            }
            setTimeout(checkReady, 10);
          });
        };

        page.open(url, function (err, status) {
          if (err) {
            return callback(err);
          }
          checkReady();
        });
      });
    });
  },
  {
    phantomPath: require('phantomjs').path
  });
};

exports.resize = function (page, values, callback) {
  page.set('viewportSize', values, function (err) {
    if (err) {
      return callback(err);
    }
    setTimeout(function () {
      callback(null, page);
    }, 500);
  });
};

exports.removeGss = function (page, callback) {
  if (typeof page == 'object') {
    page.get('content', function (err, html) {
      if (err) {
        return callback(err);
      }
      exports.removeGss(html, callback);
    });
    return;
  }
  var html = page;
  var window = jsdom.jsdom(html).createWindow();

  // Remove inline and linked GSS
  var styles = window.document.querySelectorAll('[type="text/gss"]');
  Array.prototype.slice.call(styles).forEach(function (style) {
    style.parentNode.removeChild(style);
  });

  // Remove GSS engine
  var scripts = window.document.querySelectorAll('script[src]');
  Array.prototype.slice.call(scripts).forEach(function (script) {
    if (script.src.indexOf('gss.js') === -1) {
      return;
    }
    script.parentNode.removeChild(script);
  });

  // Remove GSS IDs
  var targets = window.document.querySelectorAll('[data-gss-id]');
  Array.prototype.slice.call(targets).forEach(function (target) {
    target.removeAttribute('style');
    target.removeAttribute('data-gss-id');
  });

  callback(null, window.document.doctype + "\n" + window.document.innerHTML);
};

exports.injectCss = function (page, css, callback) {
  if (typeof page == 'object') {
    page.get('content', function (err, html) {
      if (err) {
        return callback(err);
      }
      exports.injectCss(html, css, callback);
    });
    return;
  }
  var html = page;
  var window = jsdom.jsdom(html).createWindow();

  var style = window.document.createElement('style');
  style.textContent = css;
  window.document.head.appendChild(style);

  callback(null, window.document.doctype + "\n" + window.document.innerHTML);
};

exports.gss2css = function (page, options, callback) {
  if (!callback) {
    callback = options;
    options = {};
  }
  var css = "\n";

  // Once we're done we can send the CSS
  var send = function (css) {
    exports.removeGss(page, function (err, cleaned) {
      if (err) {
        return callback(err);
      }
      exports.injectCss(cleaned, css, callback);
    });
  };

  var previous = null;
  var sizeToCss = function () {
    var size = options.sizes.shift();
    exports.resize(page, size, function (err, page) {
      page.evaluate(function () {
        return GSS.printCss();
      }, function (err, vals) {
        vals = vals.replace(/}/g, '}\n  ');
        if (options.sizes.length) {
          var next = options.sizes[0];
          if (previous) {
          css += "\n@media (min-width: " + size.width + "px) and (max-width: " + (next.width-1) + "px) {\n  " + vals + "\n}\n";
          } else {
            css += "@media (max-width: " + (next.width-1) + "px) {\n  " + vals + "\n}\n";
          }
          previous = size;
          sizeToCss();
        } else {
          css += "\n@media (min-width: " + size.width + "px) {\n  " + vals + "\n}\n";
          return send(css);
        }
      });
    });
  };

  if (!options.sizes) {
    options.sizes = [{
      width: 800,
      height: 600
    }];
  }
  sizeToCss();
};
