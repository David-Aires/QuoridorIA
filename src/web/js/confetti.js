function printWin() {
    Swal.fire({
        icon: 'info',
        title: 'Victoire!',
        text: 'Le pion '+list_players[tour].color+' remporte la partie!',

    }).then( () => {
        document.location.reload();
    });
    // the tsParticles loading script
    tsParticles.load("tsparticles", {
        fullScreen: {
            enable: true
        },
        particles: {
            number: {
                value: 0 // no starting particles
            },
            color: {
                value: ["#1E00FF", "#FF0061", "#E1FF00", "#00FF9E"] // the confetti colors
            },
            shape: {
                type: "confetti", // the confetti shape
                options: {
                    confetti: { // confetti shape options
                        type: ["circle", "square"] // you can only have circle or square for now
                    }
                }
            },
            opacity: {
                value: 1, // confetti are solid, so opacity should be 1, but who cares?
                animation: {
                    enable: true, // enables the opacity animation, this will fade away the confettis
                    minimumValue: 0, // minimum opacity reached with animation
                    speed: 2, // the opacity animation speed, the higher the value, the faster the confetti disappear
                    startValue: "max", // start always from opacity 1
                    destroy: "min" // destroy the confettis at opacity 0
                }
            },
            size: {
                value: 7, // confetti size
                random: {
                    enable: true, // enables a random size between 3 (below) and 7 (above)
                    minimumValue: 3 // the confetti minimum size
                }
            },
            life: {
                duration: {
                    sync: true, // syncs the life duration for those who spawns together
                    value: 5 // how many seconds the confettis should be on screen
                },
                count: 1 // how many times the confetti should appear, once is enough this time
            },
            move: {
                enable: true, // confetti need to move right?
                gravity: {
                    enable: true, // gravity to let them fall!
                    acceleration: 20 // how fast the gravity should attract the confettis
                },
                speed: 50, // the confetti speed, it's the starting value since gravity will affect it, and decay too
                decay: 0.05, // the speed decay over time, it's a decreasing value, every frame the decay will be multiplied by current particle speed and removed from that value
                outModes: { // what confettis should do offscreen?
                    default: "destroy", // by default remove them
                    top: "none" // but since gravity attract them to bottom, when they go offscreen on top they can stay
                }
            }
        },
        background: {
            color: "#000", // set the canvas background, it will set the style property
            opacity: 0
        },
        emitters: [ // the confetti emitters, the will bring confetti to life
            {
                direction: "top-right", // the first emitter spawns confettis moving in the top right direction
                rate: {
                    delay: 0.1, // this is the delay in seconds for every confetti emission (10 confettis will spawn every 0.1 seconds)
                    quantity: 10 // how many confettis must spawn ad every delay
                },
                position: { // the emitter position (values are in canvas %)
                    x: 0,
                    y: 50
                },
                size: { // the emitter size, if > 0 you'll have a spawn area instead of a point
                    width: 0,
                    height: 0
                }
            },
            {
                direction: "top-left", // same as the first one but in the opposite side
                rate: {
                    delay: 0.1,
                    quantity: 10
                },
                position: {
                    x: 100,
                    y: 50
                },
                size: {
                    width: 0,
                    height: 0
                }
            }
        ]
    });
}