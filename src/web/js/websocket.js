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
                PlayPoss();
                break;
            case "barr" :
                BarrPos();
                break;
            case "ia":
                if(payload.ori != null) {
                    PossBarIa();
                }
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

