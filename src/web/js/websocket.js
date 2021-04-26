const WS_PROTO = "ws://"
const WS_ROUTE = "/echo"
const connection = openWebSocket();


function log(topic, message) {
    console.log('[' + topic + '] ' + message)
}

function wsMessageHandler(event) {
    const payload = JSON.parse(event.data)
    if(payload.message != "false"){
        switch(payload.type) {
            case "play" :
                output("coucou play");
                PlayPoss();
                break;
            case "barr" :
                output("coucou barr");
                BarrPos();
                break;
            case "msg" :
                output(payload.message);
                break;
        }
    }
    else{
        clicked=[];
        output("error");
    }
}

function sendMessage(message) {
    console.log(connection.readyState)
    log("Client", "sending message \"" + message + "\"")
    connection.send(message)
}

function openWebSocket() {
    let connection = new WebSocket(WS_PROTO + window.location.host + WS_ROUTE)
    connection.onerror = (error) => {
        log("WS", error)
    }
    connection.onmessage = wsMessageHandler
    return connection
}

