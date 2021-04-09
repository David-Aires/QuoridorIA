

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
    let text_for_back = "[";
    list_players.forEach(
        elem => elem.listWall.forEach(
            elem2 => text_for_back += "(" + elem2.x + "," + elem2.y + "," + elem2.color + "," + elem2.orientation + "),"));
    if (text_for_back.length != 1){
    text_for_back = text_for_back.slice(0,-1);
    }
    text_for_back += "]";
    return text_for_back;
}

// très très gros Fix. demandez explication à David ou Sean si besoin d'explication
function allPlayer() {
    let text_for_back = "[";
    list_players.forEach(
        elem => text_for_back += "(" + Math.floor(elem.y/2) + "," + elem.x +"," + elem.color + "),");
    text_for_back = text_for_back.slice(0,-1);
    text_for_back += "]";
    return text_for_back;
}

function affichagePlacerBarriere(Wall1, Wall2) {
    console.log(allWall() + "\n" +
        allPlayer() + "\n" +
        "[(" +  Wall1.x + "," + Wall1.y + "," + Wall1.color + "," + Wall1.orientation  + "),(" + Wall2.x + "," + Wall2.y + "," + Wall2.color + "," + Wall2.orientation + ")]");
}

function affichagePlacerJoueur(player){
    console.log(allWall() + "\n" +
        allPlayer() + "\n" +
        "[(" +  Math.floor(player.y/2) + "," + player.x + "," + player.color + ")]");
}


var red_player = new Player([],'red','active_red',4,0);
var blue_player = new Player([],'blue','active_blue',0,8);
var green_player = new Player([],'darkgreen','active_green',4,16);
var yellow_player = new Player([],'gold','active_yellow',8,8);
var list_players = [blue_player,red_player,green_player,yellow_player];
var tour = 0;


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
  var $this = $(this);
  var clicked = [];
  var info = $this.data('cell').split('-');
  var row = info[0];
  var cell = info[1];

  
  clicked.push(row, cell);
  console.log(clicked);
  
  if( $this.hasClass(list_players[tour].color_class) ) return;
  
  if( Math.abs( Math.abs(clicked[0] - list_players[tour].x)) > 1 ||
      Math.abs( Math.abs(clicked[1] - list_players[tour].y)) > 2  ){
    e.preventDefault();
  } else if( (clicked[0] < list_players[tour].x) && $('span.border-h[data-border-h=' +(list_players[tour].x-1)+ '-' +(list_players[tour].y/2)+ ']').hasClass('blocked')
           || (clicked[0] > list_players[tour].x) && $('span.border-h[data-border-h=' +(list_players[tour].x)+ '-' +(list_players[tour].y/2)+ ']').hasClass('blocked')
           || (clicked[1] < list_players[tour].y) && $('span.border-v[data-border-v=' +(list_players[tour].x)+ '-' +(list_players[tour].y-1)+ ']').hasClass('blocked')
          || (clicked[1] > list_players[tour].y) && $('span.border-v[data-border-v=' +(list_players[tour].x)+ '-' +(list_players[tour].y+1)+ ']').hasClass('blocked')){
    $('#movement').append("<div><b style='color:"+ list_players[tour].color+"'>Player :</b> blocked!->" + (list_players[tour].x)+ '-' +(list_players[tour].y/2)+"</div>");
    return false;    
  }else{ 
      $("."+list_players[tour].color_class).removeClass(list_players[tour].color_class);
      if (arr[row][cell][1] === false) { 
        $this.addClass(list_players[tour].color_class);
        
        //make current attribute of active true, previous cell - false
        arr[row][cell][1] = !arr[row][cell][1];
        arr[clicked[0]][clicked[1]][1] = false;
        list_players[tour].x = clicked[0];
        list_players[tour].y = clicked[1];
      };
      $('#movement').append("<div><b style='color:"+ list_players[tour].color+"'>Player :</b> Move to "+ info);
      switch_tour();
  }  
});

// vertical 0, horizontal 1
$(document).on('click', '.border-v, .border-h', function(e){
  var info_classe = ($(this).attr('class'));
  var info = $(this).data(info_classe).split('-');
  let barrier_ = [parseInt(info[0]),parseInt(info[1])];
  if (info_classe == 'border-h') {
    if (info[1] == '8') {
        Wall1 = new Wall(barrier_[1],barrier_[0],list_players[tour].color, 1 );
        Wall2 = new Wall(--barrier_[1], barrier_[0],list_players[tour].color, 1 );
        $($(this).addClass('blocked').prev('.border-h').addClass('blocked'));
    } else {
        Wall1 = new Wall(barrier_[1],barrier_[0],list_players[tour].color, 1 );
        Wall2 = new Wall(++barrier_[1], barrier_[0],list_players[tour].color, 1 );
      $($(this).addClass('blocked').next('.border-h').addClass('blocked'));
    }
  }
  else {
    $($(this).addClass('blocked'));
    if (info[0] == '8') {
        Wall1 = new Wall((Math.floor(barrier_[1]/2)),barrier_[0],list_players[tour].color, 0 );
        Wall2 = new Wall((Math.floor(barrier_[1]/2)),--barrier_[0],list_players[tour].color, 0 );
      $('.border-v[data-border-v='+(--info[0])+'-'+info[1]+']').addClass('blocked');
    } else {
        Wall1 = new Wall((Math.floor(barrier_[1]/2)),barrier_[0],list_players[tour].color, 0 );
        Wall2 = new Wall((Math.floor(barrier_[1]/2)),++barrier_[0],list_players[tour].color, 0 );
      $('.border-v[data-border-v='+(++info[0])+'-'+info[1]+']').addClass('blocked');
    }
  }
  $('#movement').append("<div><b style='color:"+ list_players[tour].color+"'>Player :</b> Barrier to "+ info);
  affichage(Wall1, Wall2);
  list_players[tour].listWall.push(Wall1);
  list_players[tour].listWall.push(Wall2);
  switch_tour();
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





