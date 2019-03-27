'use strict';

var URL = require('url').URL;
var path = require('path');

var directoryIndexKey = "${index_document}";

exports.handler = (event, context, callback) => {
    var cf = event.Records[0].cf;
    var uri = cf.request.uri;
    var response = cf.response;
    console.log("Processing response for URI: " + uri);
    console.log("Original response code: " + response.status);
    
    // Discard query string & hash
    var urlObject = new URL("https://www.example.com" + uri);
    uri = urlObject.pathname;

    if (response.status === "403" && uri.slice(-1) !== "/" && uri.slice(0 - directoryIndexKey.length) !== directoryIndexKey) {
        // Add trailing slash
        uri += '/';
        // Restore query string & hash
        uri += urlObject.search + urlObject.hash;

        // Redirect
        response.status = "301";
        response.statusDescription = "Moved Permanently";
        response.body = "";
        response.headers["location"] = [{
            key: "Location",
            value: uri
        }];
        console.log("301 redirecting to ", uri);
    }
    
    return callback(null, response);
};