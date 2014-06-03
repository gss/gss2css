var phantom = require('node-phantom-ws');
var jsdom = require('jsdom');
exports.open = function (url, callback) {
  phantom.create(function (err, ph) {
    if (err) {
      return callback(err);
    }
    ph.createPage(function (err,page) {
      if (err) {
        return callback(err);
      }
      page.onError = function (msg, trace) {
        console.log(msg);
      };
      page.open(url, function (err, status) {
        callback(err, page);
      });
    });
  },
  {
    phantomPath: require('phantomjs').path
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
