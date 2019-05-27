var express = require('express');
var router = express.Router();
var request = require('request');

router.post('/', function (req,res,err) {
    var fs = require('fs');
    //var flaskURL = (process.env.API_HOST) ? process.env.API_HOST + '/v1/unsubscribe/' : 'http://127.0.0.1:3003/v1/unsubscribe';
    //req will contain the selected unsubs(minus the _subbed tag so it can match the text file
    //remove found regex OR reprint text file without the unsubbed classes
    var client_unsub_array = req.body["client_unsub_array"];
    var to_file = "";
    for(var i = 0; i < client_unsub_array.length; i++) {
        to_file = to_file + client_unsub_array[i] + "\n";
    }
    fs.truncate('/path/to/file', 0, function(){
        fs.writeFile('./temp_files/temp.txt', to_file, {encoding:'utf8',flag:'w'}, (err) => {
            if (err) throw err;
            return res.json(client_unsub_array);
        });
    });
});

module.exports = router;