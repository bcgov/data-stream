var express = require('express');
var router = express.Router();
var request = require('request');

router.get('/', function(req, res, next) {
    var fs = require('fs');
    fs.readFile('./temp_files/temp.txt', 'utf-8', function(err, data) {
        var split_data = data.split("\n");
        res.send(JSON.stringify(split_data));
    });
});

module.exports = router;