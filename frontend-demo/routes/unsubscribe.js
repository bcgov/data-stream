var express = require('express');
var router = express.Router();
var request = require('request');

router.post('/', function (req,res,err) {
    var fs = require('fs');
    //var flaskUrl = 'http://localhost:3003/v1/unsubscribe';
    var flaskUrl = (process.env.API_HOST) ? process.env.API_HOST + '/v1/unsubscribe/' : 'http://127.0.0.1:3003/v1/unsubscribe';
    var flask_unsub_array = req.body['flask_unsub_array'];
    for(var i = 0; i < flask_unsub_array.length; i++) {
        var unsub = flask_unsub_array[i]
        unsub = unsub.replace('-', '.');
        unsub = 'file://' + unsub;
        flask_unsub_array[i] = unsub;
    }
    var file_unsub_array  = req.body['client_unsub_array'];
    //make a for loop to unsubsribe each o
    const options = {
        method: 'POST',
        headers: {
            'User-Agent': 'request',
            // 'id': 'user1',
            // 'x-api-key': 'pass1'
            'id': process.env.API_USER,
            'x-api-key': process.env.API_PASS
        },
        body: {
            'datasetId': JSON.stringify(flask_unsub_array),
            //'notificationUrl': (process.env.HOST) ? process.env.HOST + '/notify' : 'http://127.0.0.1:3000/notify' //demo value
            'notificationUrl': (process.env.HOST) ? process.env.HOST + '/notify' : 'http://127.0.0.1:3000/notify'
        },
        json: true
    };
    request(flaskUrl, options, function (error, response, body) {
        if(error) {
            console.log(error);
        }
        else if(response) {
            console.log(response.body.message);
            var to_file = "";
            for(var i = 0; i < file_unsub_array.length; i++) {
                to_file = to_file + file_unsub_array[i] + "\n";
            }
            fs.truncate('/path/to/file', 0, function(){
                fs.writeFile('./temp_files/temp.txt', to_file, {encoding:'utf8',flag:'w'}, (err) => {
                    if (err) throw err;
                    return res.json(response.body.message);
                });
            });
        }
        //request async, need to contain the send here to guarantee both are attached to the response
    });
    //req will contain the selected unsubs(minus the _subbed tag so it can match the text file
    //remove found regex OR reprint text file without the unsubbed classes
});

module.exports = router;