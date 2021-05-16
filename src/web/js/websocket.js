const WS_PROTO = "ws://"
const WS_ROUTE = "/echo"
const connection = openWebSocket();


function log(topic, message) {
    console.log('[' + topic + '] ' + message)
}

function wsMessageHandler(event) {
    const payload = JSON.parse(event.data);
    if(payload.message != "false"){
        switch(payload.type) {
            case "play" :
                PlayPoss();
                break;
            case "barr" :
                BarrPos();
                break;
            case "ia":
                var x = parseInt(payload.posX);
                var y = parseInt(payload.posY);
                console.log("type: "+payload.type);
                console.log("Back x: "+ x);
                console.log("Back y: "+y);
                if(payload.ori < 2) {
                    console.log("orientation:"+payload.ori);
                    BarrPosIA(x,y,payload.ori);
                } else {
                    PlayPosIA(x,y);
                }
                break;
            case "msg" :
                output(payload.message);
                break;
        }
    }
    else{
        clicked=[];
        Toast.fire({
            icon: 'error',
            title: 'Mouvement impossible !'
        })
    }
}

const Toast = Swal.mixin({
    toast: true,
    position: 'top-end',
    iconColor: 'white',
    customClass: {
        popup: 'colored-toast'
    },
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    didOpen: (toast) => {
        toast.addEventListener('mouseenter', Swal.stopTimer)
        toast.addEventListener('mouseleave', Swal.resumeTimer)
    }
});

function wsReconnect(e) {
    console.log('Socket is closed. Reconnect will be attempted in 1 second.', e.reason);
    setTimeout(function() {
        openWebSocket();
    }, 1000);
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
    connection.onclose = wsReconnect


    return connection
}

