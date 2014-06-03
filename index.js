var phantom = require('node-phantom-ws');
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
