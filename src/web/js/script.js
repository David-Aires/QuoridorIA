//var grid = new PF.Grid(5, 3);

/* Some kind of LOGIC */
var current= [8,8];
var blockers = 0;
var maxBlockers = 9;

$(document).on('click', '.cell', function(e){ 
  var $this = $(this);
  var clicked = [];
  var info = $this.data('cell').split('-'); 
  var row = info[0];
  var cell = info[1];
  
  clicked.push(row, cell);
  
  if( $this.hasClass('active') ) return;
  
  if( Math.abs( Math.abs(clicked[0] - current[0])) > 1 ||
      Math.abs( Math.abs(clicked[1] - current[1])) > 2  ){ 
    $('.debug').text('to far!');  
    e.preventDefault();
  } else if( (clicked[0] < current[0]) && $('span.border-h[border-h=' +(current[0]-1)+ '-' +(current[1]/2)+ ']').hasClass('blocked')
           || (clicked[0] > current[0]) && $('span.border-h[border-h=' +(current[0])+ '-' +(current[1]/2)+ ']').hasClass('blocked') 
           || (clicked[1] < current[1]) && $('span.border-v[data-border-v=' +(current[0])+ '-' +(current[1]-1)+ ']').hasClass('blocked')
          || (clicked[1] > current[1]) && $('span.border-v[data-border-v=' +(current[0])+ '-' +(parseInt(current[1])+1)+ ']').hasClass('blocked')){
    $('.debug').text('blocked!' + (current[0])+ '-' +(current[1]/2)); 
    return false;    
  }else{ 
      $('.active').removeClass('active');
      if (arr[row][cell][1] === false) { 
        $this.addClass('active');
        
        //make current attribute of active true, previous cell - false
        arr[row][cell][1] = !arr[row][cell][1];
        arr[clicked[0]][clicked[1]][1] = false;
        current = clicked;
      };
      $('.debug').text(info + " " + arr[row][cell][1] + "- Walls remainded " + (maxBlockers - blockers ) );
  }  
});

$(document).on('mousedown', '.border-v, .border-h', function(e){ 
  blockers++;
  if ( blockers > maxBlockers ) return;
  $( $(this).addClass('blocked').next('.border-h').addClass('blocked') )
});
                        
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
      html += '<span class="border-h" border-h='+i+'-'+ll+'></span>';
    }

    html += '</div>';
  }
   
}


$( document ).ready(function() {
    $('.app').append(html)
});

 



$('span[data-cell="8-8"]').addClass('active');




$(document).on("mouseenter mouseleave",'.border-v', hoverFunct);

function hoverFunct(){
  var $this = $(this);
  var info = $this.data('border-v').split('-');  
  $('.border-v[data-border-v='+(++info[0])+'-'+info[1]+']').toggleClass('hover');  
};


$(document).on('click','.border-v', clickFunc);

function clickFunc(){ 
  if ( blockers > maxBlockers ) return;
  var $this = $(this);
  var info = $this.data('border-v').split('-');  
  $('.border-v[data-border-v='+(++info[0])+'-'+info[1]+']').toggleClass('blocked'); 
  blockers++;
}; 






