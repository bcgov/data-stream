var express = require('express');
var router = express.Router();
const WebSocket = require('ws');

var chunkData = {};
var chunks_received = 0;
var filename = "";
/*posts data to another post request to deliver to the flask API*/
router.post('/', function(req, res, next) {
    console.log('Server notified.');
    console.log(req.body);
    res.status(200).end();
    chunkData[req.body.datasetId + " " + req.body.part] = req.body.data;
    chunks_received += 1;
    filename = req.body.filename;
    // var keys = Object.keys(chunkData);
    // console.log(keys);
    // if (keys.indexOf(req.body.datasetId) === -1){
    //     chunkData[req.body.datasetId] = {};
    // }

    if(req.body.part === req.body.chunks) {
        console.log("Last chunk!");
        console.log(chunks_received);
        //console.log(chunkData);
        var websockets = require('../public/javascripts/web_socket');
        var conns = websockets.getConnections();
        console.log(conns);
        for (var i=0; i<conns.length; i++) {
            conns[i].send(JSON.stringify(chunks_received + " chunks received from " + filename + " at " + Date.now()));
        }
        chunks_received=0;
        // var websockets = require('../public/javascripts/web_socket');
        // var conns = websockets.getConnections();
        // var wskeys = Object.keys(conns);
        // for (var i=0; i<wskeys.length; i++){
        //     checkTopicPermissions(conns[wskeys[i]].user, topic._id, conns[wskeys[i]], function(send, sock) {
        //         if (send) {
        //             if (websockets.isOpen(sock)) {
        //                 sock.send(JSON.stringify(req.body));
        //             }
        //         }
        //     });
        // }

    }

    //Get Socket from WS Server
    // var sock = getSock();
    // sock.send({data: req.body});

    //postNotification(res.body);
});



module.exports = router;
