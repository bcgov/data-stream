var express = require('express');
var router = express.Router();
const WebSocket = require('ws');

notificationData = {};
/*posts data to another post request to deliver to the flask API*/
router.post('/', function(req, res, next) {

    console.log(req.body.notificationId);
    res.status(200).end();
    var notificationDataKey = req.body.datasetId+"("+req.body.notificationId+")";
    if (!(Object.keys(notificationData)).includes(notificationDataKey)) {
        notificationData[notificationDataKey] = {};
    }
    var chunkData = notificationData[notificationDataKey];
    chunkData[req.body.part] = req.body.data;
    notificationDataKey[notificationDataKey] = chunkData;
    console.log("current chunks sent from notification " + notificationDataKey + " = " + Object.keys(notificationData[notificationDataKey]).length);
    //notificationDataKey[notificationDataKey][req.body.part] = req.body.data;
    // var keys = Object.keys(chunkData);
    // console.log(keys);
    // if (keys.indexOf(req.body.datasetId) === -1){
    //     chunkData[req.body.datasetId] = {};
    // }

    if(Object.keys(notificationData[notificationDataKey]).length === req.body.chunks) {
        console.log("Last chunk!");
        //console.log(chunkData);
        var websockets = require('../public/javascripts/web_socket');
        var conns = websockets.getConnections();
        //console.log(conns);
        for (var i=0; i<conns.length; i++) {
            //conns[i].send(JSON.stringify(notificationData[notificationDataKey]));
            conns[i].send(JSON.stringify(req.body.chunks + " chunks received from " + req.body.datasetId + " at " + req.body.notificationId));
        }
        console.log(notificationData[notificationDataKey]);
        console.log("Finished notifying for " + req.body.datasetId + " at " + notificationDataKey);
        delete notificationData[notificationDataKey];
        console.log(notificationData);
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
