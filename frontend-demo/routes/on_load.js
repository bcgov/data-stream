var express = require('express');
var router = express.Router();
var request = require('request');

router.get('/', function(req, res, next) {
    var fs = require('fs');
    fs.access('./temp_files/temp.txt', error => {
        //if file exists
        if(!error) {
            fs.readFile('./temp_files/temp.txt', 'utf-8', function(err, data) {
                var split_data = data.split("\n");
                res.send(JSON.stringify(split_data));
            });
        } else {
            console.log(error);
            fs.writeFile('./temp_files/temp.txt', '', {flag : 'wx'}, function () {
                var empty_array = [];
                res.send(JSON.stringify((empty_array)));
            });
        }
    });
});

module.exports = router;