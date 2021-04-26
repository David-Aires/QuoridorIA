

/*
Création de l'objet joueur et initialisation des différents joueurs avec leur position de base et leur classe de couleur
*/
function Player(listWall,color,color_class,x,y) {
  this.listWall= listWall;
  this.color = color;
  this.color_class = color_class;
  this.x = x;
  this.y = y;
}
// ->  [[1,2,B,0],[1,3,B,0]]
// -> [(1,2,B,0),(1,3,B,0)]
function Wall(x, y, color, orientation){
    this.x = x;
    this.y = y;
    this.color = color;
    this.orientation = orientation;
}

function allWall() {
    let list_wall = [];
    list_players.forEach(
        elem => elem.listWall.forEach(
            elem2 => {
                list_wall.push([elem2.x, elem2.y, elem2.color, elem2.orientation]);
            }));

    return list_wall;
}

// très très gros Fix. demandez explication à David ou Sean si besoin d'explication
function allPlayer() {
    let list_player = [];
    list_players.forEach(
        elem => list_player.push([Math.floor(elem.y/2),parseInt(elem.x),elem.color]));
    return list_player;
}

function barrPositionChange() {
    let pos_barr = [wall2.x, wall2.y, wall2.orientation];
    let pos_player = [Math.floor(list_players[tour].y/2),parseInt(list_players[tour].x),list_players[tour].color];
    let listWall2 = allWall();
    listWall2.push([wall1.x, wall1.y, wall1.color, wall1.orientation]);
    const payloadBarr = {
        type: "barr",
        listWalls: listWall2,
        listPlayers: allPlayer(),
        posPlayer: pos_player,
        posBarr: pos_barr
    };
    sendMessage(JSON.stringify(payloadBarr));
}

function playerPositonChange(x, y){
    let pos_player_now = [Math.floor(list_players[tour].y/2),parseInt(list_players[tour].x), list_players[tour].color];
    let pos_player = [Math.floor(y/2),parseInt(x)];
    const payloadPlayer = {
        type: 'play',
        listWalls: allWall(),
        listPlayers: allPlayer(),
        posPlayerNow : pos_player_now,
        posPlayer: pos_player
    };
    sendMessage(JSON.stringify(payloadPlayer))
}

function BarrPos(){
    var info_classe = (event.attr('class'));
    var info = event.data(info_classe).split('-');
    if (info_classe == 'border-h') {
        if (info[1] == '8') {
            $(event.addClass('blocked').prev('.border-h').addClass('blocked'));
        } else {
            $(event.addClass('blocked').next('.border-h').addClass('blocked'));
        }
    }
    else {
        $(event.addClass('blocked'));
        if (info[0] == '8') {
            $('.border-v[data-border-v='+(--info[0])+'-'+info[1]+']').addClass('blocked');
        } else {
            $('.border-v[data-border-v='+(++info[0])+'-'+info[1]+']').addClass('blocked');
        }
    }
    $('#movement').append("<div><b style='color:"+ list_players[tour].color+"'>Player :</b> Barrier to "+ info);
    list_players[tour].listWall.push(wall1);
    list_players[tour].listWall.push(wall2);
    switch_tour();
}

function PlayPoss(){
    $("."+list_players[tour].color_class).removeClass(list_players[tour].color_class);
    if (arr[clicked[0]][clicked[1]][1] === false) {
        event.addClass(list_players[tour].color_class);

        //make current attribute of active true, previous cell - false
        arr[clicked[0]][clicked[1]][1] = !arr[clicked[0]][clicked[1]][1];
        arr[clicked[0]][clicked[1]][1] = false;
        list_players[tour].x = parseInt(clicked[0]);
        list_players[tour].y = parseInt(clicked[1]);
    };
    $('#movement').append("<div><b style='color:"+ list_players[tour].color+"'>Player :</b> Move to "+ info);
    switch_tour();
}

var red_player = new Player([],'red','active_red',4,0);
var blue_player = new Player([],'blue','active_blue',0,8);
var green_player = new Player([],'darkgreen','active_green',4,16);
var yellow_player = new Player([],'gold','active_yellow',8,8);
var list_players = [blue_player,red_player,green_player,yellow_player];
var tour = 0;
var event = null;
var wall1 = null;
var wall2 = null;
var clicked = [];

const ANIM_END = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';

//##################################################################################################################################################################################################

function switch_tour() {
  tour++;
  if(tour == 4) tour = 0;
  let current_player = $(".card").attr("class").split(' ')[1];
  $("#cards").removeClass("unfold");
  $("#cards").addClass("spin").one(ANIM_END, function () {
      setTimeout(function () {
          $("#cards").removeClass("spin");
      }, 20);
  });
  $( ".card" ).removeClass(current_player).addClass("card--"+list_players[tour].color);
  if (tour == 3 || tour == 2) {
    $(".card__type").text("IA");
  } else {
    $(".card__type").text("Joueur");
  }
    $("#pos_X").text(list_players[tour].x);
    $("#pos_Y").text(list_players[tour].y);
    $("#wall").text(list_players[tour].wall);
    clicked = [];
    wall1 = null;
    wall2 = null;
    event = null;
}

//##################################################################################################################################################################################################
/*
Action lorsque le joueur souhaite déplacer son pion sur le plateau :
  - Suppression de la couleur du joueur sur la case précédente
  - Ajout de la couleur du joueur sur la case souhaité
  - Envoie demande de déplacement au serveur prolog
* */

$(document).on('click', '.cell', function(e){
  //if(tour==3 || tour==2) return;
  event = $(this);
  var info = $this.data('cell').split('-');
  clicked.push(info[0], info[1]);
  console.log(clicked);

  if( event.hasClass(list_players[tour].color_class) ) return;
  playerPositonChange(clicked[0], clicked[1]);
});

// vertical 0, horizontal 1
$(document).on('click', '.border-v, .border-h', function(e){
    var info_classe = ($(this).attr('class'));
    var info = $(this).data(info_classe).split('-');
    let barrier_ = [parseInt(info[0]),parseInt(info[1])];
    if (info_classe == 'border-h') {
        if (info[1] == '8') {
            wall1 = new Wall(barrier_[1],barrier_[0],list_players[tour].color, 1 );
            wall2 = new Wall(--barrier_[1], barrier_[0],list_players[tour].color, 1 );
        } else {
            wall1 = new Wall(barrier_[1],barrier_[0],list_players[tour].color, 1 );
            wall2 = new Wall(++barrier_[1], barrier_[0],list_players[tour].color, 1 );
        }
    }
    else {
        $(event.addClass('blocked'));
        if (info[0] == '8') {
            wall1 = new Wall((Math.floor(barrier_[1]/2)),barrier_[0],list_players[tour].color, 0 );
            wall2 = new Wall((Math.floor(barrier_[1]/2)),--barrier_[0],list_players[tour].color, 0 );
        } else {
            wall1 = new Wall((Math.floor(barrier_[1]/2)),barrier_[0],list_players[tour].color, 0 );
            wall2 = new Wall((Math.floor(barrier_[1]/2)),++barrier_[0],list_players[tour].color, 0 );
        }
    }
    event = $(this);
    barrPositionChange();
});

//##################################################################################################################################################################################################
/*
Création du plateau de jeu
*/

var arr = [];
 
for(var h =0; h < 9; h++){
  arr.push([]); 
  for(var i =0; i < 9; i++){arr[h].push([i,false]);
    if ( i < 8) arr[h].push(['border', false]);
  } 
  
  /* border row */
  arr[h].push([]);
  
  for (var ii = 1; ii <= 9; ii++) {
      arr[h][17].push(ii);
  }  
} 

console.log(arr);

 /* Some kind of VIEW */
var html = '';
for (var i = 0; i < arr.length; i++) { 
  html += '<div class="row">';
  
  for (var l = 0; l < arr[0].length-1; l++) {
    
    if( arr[0][l][0] !='border') { 
      html += '<span class="cell" data-cell='+i+'-'+l+'></span>';
    } else {      
      html += '<span class="border-v" data-border-v='+i+'-'+l+'></span>';
    }
  }   
  html += '</div>';
  
  /*  check if the last row, we dont need border */
  if (i<8){
    html +='<div class="border-row">'; 
  
    for (var ll = 0; ll <9; ll++) {
      html += '<span class="border-h" data-border-h='+i+'-'+ll+'></span>';
    }

    html += '</div>';
  }
   
}


//##################################################################################################################################################################################################
/*
Affichage du plateau lors du chargement de la page & placement des positions de base des joueurs
*/
$( document ).ready(function() {
    $('.app').append(html)
    $('span[data-cell="0-8"]').addClass('active_blue');
    $('span[data-cell="4-0"]').addClass('active_red');
    $('span[data-cell="4-16"]').addClass('active_green');
    $('span[data-cell="8-8"]').addClass('active_yellow');
});




//##################################################################################################################################################################################################
/*
Action lors de passsage sur une bordure:
  - Ajoute la classe hover ou la retire (toggle)
*/

$(document).on("mouseenter mouseleave",'.border-v', hoverFunct_V);
$(document).on("mouseenter mouseleave",'.border-H', hoverFunct_H);

function hoverFunct_H(){
    var info = $(this).data('border-h').split('-');
    if (info[1] == '8') {
        $($(this).toggleClass('hover').prev('.border-h').toggleClass('hover'));
    } else {
        $($(this).toggleClass('hover').next('.border-h').toggleClass('hover'));
    }
}

function hoverFunct_V() {
        var info = $(this).data('border-v').split('-');
        if (info[0] == '8') {
            $('.border-v[data-border-v='+(--info[0])+'-'+info[1]+']').toggleClass('hover');
        } else {
            $('.border-v[data-border-v='+(++info[0])+'-'+info[1]+']').toggleClass('hover');
        }
}





