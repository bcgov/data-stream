var express = require('express');
var router = express.Router();
var request = require('request');

/*posts data to another post request to deliver to the flask API*/
router.post('/', function(req, res, next) {
    var fs = require('fs');
    var sub_array = req.body;
    var flaskURL = (process.env.API_HOST) ? process.env.API_HOST + '/v1/subscribe/' : 'http://127.0.0.1:3003/v1/subscribe';
    //var flaskURL = 'http://127.0.0.1:3003/v1/subscribe';

    res_json = [];


    fs.readFile('./temp_files/temp.txt', 'utf-8', function (err, data) {

        for (var i = 0; i < sub_array.length; i++) {
            if (data.includes(sub_array[i])) {
                console.log(sub_array[i] + " is already subscribed to.");
                continue;
            } else {
                //delete later when dynamic file testing is tested and ready
                var datasetId = sub_array[i];
                datasetId = datasetId.replace('-', '.');
                if (sub_array[i]==="prot_current_fire_points.shp")  {
                    datasetId = "file://prot_current_fire_points/" + datasetId;
                } else if (sub_array[i]==="prot_current_fire_polys.shp") {
                    datasetId = "file://prot_current_fire_polys/" + datasetId;
                } else {
                    var datasetId = "file://" + datasetId;
                }
                console.log(sub_array[i] + " will be subscribed to.");

                const options = {
                    method: 'POST',
                    headers: {
                        'User-Agent': 'request',
                        'id': process.env.API_USER,
                        'x-api-key': process.env.API_PASS
                    },
                    body: {
                        'datasetId': datasetId,
                        'notificationUrl': (process.env.HOST) ? process.env.HOST + '/notify' : 'http://127.0.0.1:3000/notify' //demo value
                        //http://127.0.0.1:3000/notify'
                    },
                    json: true
                };

                request(flaskURL, options, function (error, response, body) {
                    res_json.push(body);
                    //request async, need to contain the send here to guarantee both are attached to the response
                    if (sub_array.length === res_json.length) {
                        res.json(res_json);
                    }
                })
            }
        }
    });

});

module.exports = router;