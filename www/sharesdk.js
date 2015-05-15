
var exec = require("cordova/exec");

var ShareSdk = function () {
    this.name = "ShareSdk";
};

ShareSdk.prototype.send = function (message) {
    if (!message) {
        return;
    } 
    exec(null, null, "sharesdk.cordova", "send", [message]);
};

module.exports = new ShareSdk();
