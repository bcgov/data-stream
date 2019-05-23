var express = require('express');
var router = express.Router();
var request = require('request');

router.get('/', function(req, res, next) {
    var fs = require('fs');
    fs.truncate('./temp_files/temp.txt', 0, function(){console.log('done')});
    res.send('Done');
});

module.exports = router;