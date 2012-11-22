var page = require('webpage').create();
var fs = require('fs');

$ = window.$;
page.viewportSize = { width: 1000, height: 500 };
page.content = fs.read (phantom.args[0]);

console.log(page.renderBase64('PNG'));
phantom.exit();


