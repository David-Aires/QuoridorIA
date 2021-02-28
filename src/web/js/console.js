// Output Welcome message
$(document).ready(function() {
    output('Bonjour, je suis QBot, le bot explicateur de QuoridorIA.')
    output('')
    output('En quoi puis-je vous aider ?')
});

// User Commands
var cmds = {
    clear
}

/*
 * * * * * * * * USER INTERFACE * * * * * * *
 */

function clear () {
    $("#outputs").html("")
}
clear.usage = "clear"
clear.doc = "Clears the terminal screen"


// Set Focus to Input
$('.console').click(function() {
    $('.console-input').focus()
})

// Display input to Console
function input() {
    var cmd = $('.console-input').val()
    $("#outputs").append("<div class='output-cmd'>" + cmd + "</div>")
    $('.console-input').val("")
    autosize.update($('textarea'))
    $("html, body").animate({
        scrollTop: $(document).height()
    }, 300);
    return cmd
}

// Output to Console
function output(print) {
    if (!window.md) {
        window.md = window.markdownit({
            linkify: true,
            breaks: true
        })
    }
    $("#outputs").append(window.md.render(print))
    $(".console").scrollTop($('.console-inner').height());
}

// Break Value
var newLine = "<br/> &nbsp;";

autosize($('textarea'))

var cmdHistory = []
var cursor = -1

// Get User Command
$(document).on('keydown','.console-input', function(event) {
    if (event.which === 38) {
        // Up Arrow
        cursor = Math.min(++cursor, cmdHistory.length - 1)
        $('.console-input').val(cmdHistory[cursor])
    } else if (event.which === 40) {
        // Down Arrow
        cursor = Math.max(--cursor, -1)
        if (cursor === -1) {
            $('.console-input').val('')
        } else {
            $('.console-input').val(cmdHistory[cursor])
        }
    } else if (event.which === 13) {
        event.preventDefault();
        cursor = -1
        let text = input()
        let args = getTokens(text)[0]
        let cmd = args.shift().value
        args = args.filter(x => x.type !== 'whitespace').map(x => x.value)
        cmdHistory.unshift(text)
        if (typeof cmds[cmd] === 'function') {
            let result = cmds[cmd](...args)
            if (result === void(0)) {
                // output nothing
            } else if (result instanceof Promise) {
                result.then(output)
            } else {
                output(result)
            }
        } else if (cmd.trim() === '') {
            output('')
        } else {
            const payload = {
                message: text
            }
            sendMessage(JSON.stringify(payload))
        }
    }
});


