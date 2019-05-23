
var express = require('express');
var router = express.Router();
var request = require('request');

router.get('/', function(req, res, next) {

    //var flaskURL = 'http://data-stream-wlev6y-dev.pathfinder.gov.bc.ca';
    var flaskURL = (process.env.API_HOST) ? process.env.API_HOST + '/' : 'http://127.0.0.1:3003';
    //var flaskURL = 'http://127.0.0.1:3003';

    const options = {
        url: flaskURL,
        headers: {
            'User-Agent': 'request'
        }
    };

    request(options, function(error, response, body) {
        if(response===undefined) {
            res.send(error);
        } else {
            res.send(response);
        }
    });
    // http.get(flaskURL, function(err, response) {
    //     console.log('connection attempted');
    //     res.setHeader('Connection', 'Success');
    //     res.send();
    // })

    // fetch(flaskURL, {method: 'GET'})
    //     .then(function (response) {
    //         console.log(response);
    //         res.body="Connection found.";
    //         res.send();
    //     })
    //     .catch(function (err) {
    //         console.log(err);
    //         res.body="Connection failed.";
    //         res.send();
    //     })
});

module.exports = router;