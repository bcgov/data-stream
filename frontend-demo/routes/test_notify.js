var express = require('express');
var router = express.Router();
var request = require('request');

router.get('/', function(req, res, next) {

    var flaskURL = (process.env.API_HOST) ? process.env.API_HOST + '/v1/notify' : 'http://127.0.0.1:3003/v1/notify';
    //var flaskURL = 'http://127.0.0.1:3003/v1/notify';
    var datasetId = 'file://lightning_BC_Jul2018.csv';
    //var datasetId = 'file://prot_current_fire_polys/prot_current_fire_polys.shp';
    //var datasetId = 'file://prot_current_fire_polys/prot_current_fire_polys.shp';
    const options = {
        method: 'POST',
        headers: {
            'User-Agent': 'request',
            'id': 'user1',
            'x-api-key': 'pass1'
        },
        body: {
            'datasetId': datasetId
        },
        json: true
    };
    request(flaskURL, options, function (error, response, body) {
        if(error) {
            console.log('Notify error: ' + error);
            res.send(error);
        } else {
            console.log(body);
            res.send(body);
        }
    });
});

module.exports = router;