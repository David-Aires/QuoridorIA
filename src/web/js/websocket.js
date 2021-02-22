const WS_PROTO = "ws://"
const WS_ROUTE = "/echo"
const connection = openWebSocket();


function log(topic, message) {
    console.log('[' + topic + '] ' + message)
}

function wsMessageHandler(event) {
    const payload = JSON.parse(event.data)
    log("WS Response", "Received message: '" + event.data + "'")
    output(payload.message)
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

