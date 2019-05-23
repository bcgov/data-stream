var websocket = {};

const WebSocket = require('ws');

websocket.connections = [];
websocket.server = null;

websocket.init = function(){
    var self = this;

    this.server = new WebSocket.Server({
        port: 3001,
        perMessageDeflate: false,
    });

    function heartbeat() {
        this.isAlive = true;
    }

    this.server.on('connection', function connection(ws, req) {
        console.log("Websocket connection opened with: " + ws);
        ws.isAlive = true;
        ws.on('pong', heartbeat);
        self.connections.push(ws);
        //console.log(self.connections);
    });


//terminate stale websockets
    const interval = setInterval(function ping() {
        self.server.clients.forEach(function each(ws) {
            if (ws.isAlive === false) return ws.terminate();

            ws.isAlive = false;
            ws.ping(function(){});
        });
    }, 30000);
};

websocket.getConnections = function(){
    return this.connections;
};

websocket.updateClient = function(message, id){
    this.connections[id].send(message);
};

websocket.isOpen = function (client) {
    return (client.readyState === WebSocket.OPEN);
};

module.exports = websocket;