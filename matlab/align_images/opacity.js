var img1, img2, ctx, canvas;
var state = 0, view_option = 2;
var apply_translation = true, apply_scale = true;
var H, points = [];
var scale = 1, x_translation = 0, y_translation = 0;
var instructions = [
  "[1/2] - Find 2 landmarks not aligned between image 1 and image 2. Click on their positions in image 1",
  "[2/2] - Now click on their positions in image 2",
  "<b>Transformation Computed</b> To Start again , just click again on the landmarks"
];


function save(){
  var buffer = document.createElement('canvas');
  buffer.width = img2.width;
  buffer.height = img2.height;
  ctx = buffer.getContext('2d');
  ctx.setTransform(scale, 0, 0, scale, x_translation, y_translation);
  ctx.drawImage(img2, 0, 0);
  var dataURL = buffer.toDataURL();
}

function drawing(opacity_level){
  if (opacity_level == undefined) {
    opacity_level = $("#slider1").slider("option", "value") / 100.0;
  }
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  ctx.globalAlpha = 1;
  ctx.drawImage(img1, 0, 0);

  if (opacity_level > 0){
    transform_image();
    ctx.globalAlpha = opacity_level;
    ctx.drawImage(img2, 0, 0);
  }
}

var transform_image = function() {
    //if (state == 2) {
      console.log(H);
      console.log(scale+" "+x_translation+" "+y_translation);
      switch (view_option) {
        case 0:
          break;
        case 1:
          //ctx.translate(H.translating.x, H.translating.y);
          ctx.translate(x_translation, y_translation); /// H.translating.y);

          break;
        case 2:
         
          //ctx.translate(x_translation, y_translation); //H.translating.y);
          // ctx.scale(scale,scale); 
           ctx.setTransform(scale, 0, 0, scale, 
            x_translation, 
            y_translation);
         /* ctx.setTransform(H.scaling.ratio.x, 0, 0, H.scaling.ratio.y, 
            H.translating.x + H.scaling.center.x, 
            H.translating.y + H.scaling.center.y);*/
          break;
      }
    //}
  }


function print_instructions() {
  state = points.length / 2;
  msg = instructions[state];
  $("#msg").html(msg);
};

function reset(){
    points = [];
    state = 0;
};
     
function compute_transformation(points) {

  // translating
  diff1 = points[0].minusNew(points[2]);
  diff2 = points[1].minusNew(points[3]);

  //t_1_to_2 = diff1.plusNew(diff2).multiplyNew(0.5).plusNew(points[0]);
  
  t_1_to_2 = diff1.plusNew(diff2).multiplyNew(0.5);
  x_translation = t_1_to_2.x;
  y_translation = t_1_to_2.y;

  $("#slider_x_translation").slider({ value: x_translation });
  $("#slider_x_translation").html("X tranlation ("+x_translation+")");

  $("#slider_y_translation").slider({ value: y_translation });
  $("#slider_y_translation").html("Y tranlation ("+y_translation+")");

  //slider_x_translation
      // compute translation / new mid-point
  // var position = new THREE.Vector3().addVectors(v10, v30).multiplyScalar(0.5).add(v[0]);


  console.log("translation 1: " + diff1);
  console.log("translation 2: " + diff2);
  console.log("translation mean: " + t_1_to_2);

  // scaling
  scale_img1 = points[1].minusNew(points[0]);
  scale_img2 = points[3].minusNew(points[2]);

  // avg_scale = scale_img1.magnitude() / scale_img2.magnitude();
  scale = scale_img1.magnitude() / scale_img2.magnitude();
  $("#slider_scale").slider({ value: scale * 100 });

  ratio_x = scale_img1.magnitude() / scale_img2.magnitude();
  ratio_y = scale_img1.magnitude() / scale_img2.magnitude();
  


  //ratio_x = scale_img1.x / scale_img2.x;
  //ratio_y = scale_img1.y / scale_img2.y;

  centering_x = ((1.0 - ratio_x) * canvas.width) / 2.0;
  centering_y = ((1.0 - ratio_y) * canvas.height) / 2.0;
  centering = new Vector2(centering_x, centering_y);
  console.log("translation to center: " + centering);
  s_1_to_2 = {
    ratio: {
      x:ratio_x,
      y:ratio_y
    },
    center: centering
  };  

  return {
    translating: t_1_to_2,
    scaling: s_1_to_2
  };
}

function clicking(e) {
  if (points.length >= 4){
    reset();
  }
  points.push(get_point(e));
  if (points.length >= 4) {
    H = compute_transformation(points);
    print_instructions();
    drawing();
  }
};

function get_point(event){
  var point = {
    x: event.pageX - $(canvas).offset().left,
    y: event.pageY - $(canvas).offset().top
  };
  return new Vector2(point.x, point.y);
}

function init_ui(){
  $("input:radio[name=radio]").click(function() {
    view_option = parseInt($(this).val());
    drawing();
  });

  canvas = document.getElementById("before_canvas");
  ctx = canvas.getContext("2d");
  ctx.globalCompositeOperation = "source-over";
  $.when($.image("im2_before.jpg"), $.image("im2_after.jpg")).done(function(image1, image2) {
      img1 = image1;
      img2 = image2;
      slider = $("#slider1").slider({value: 40, min: 0, max: 100, step: 20, slide: function(event, ui) {
          drawing(ui.value / 100.0)
        }
      });
      slider = $("#slider_scale").slider({value: 100, min: 0, max: 200, step: 1, slide: function(event, ui) {
          scale = ui.value/100.0;
          drawing();
        }
      });
      slider = $("#slider_x_translation").slider({value: 0, min: -100, max: 100, step: 1, slide: function(event, ui) {
          x_translation = ui.value/canvas.width;
          drawing();
        }
      });
       slider = $("#slider_y_translation").slider({value: 0, min: -100, max: 100, step: 1, slide: function(event, ui) {
          y_translation = ui.value/canvas.height;
          drawing();
        }
      });
      drawing(0.4);
  });
  $("#before_canvas").on('click', clicking);
  print_instructions();
}

$(function() {
function onInitFs(fs) {
  console.log('Opened file system: ' + fs.name);
}

function errorHandler(e) {
  var msg = '';

  switch (e.code) {
    case FileError.QUOTA_EXCEEDED_ERR:
      msg = 'QUOTA_EXCEEDED_ERR';
      break;
    case FileError.NOT_FOUND_ERR:
      msg = 'NOT_FOUND_ERR';
      break;
    case FileError.SECURITY_ERR:
      msg = 'SECURITY_ERR';
      break;
    case FileError.INVALID_MODIFICATION_ERR:
      msg = 'INVALID_MODIFICATION_ERR';
      break;
    case FileError.INVALID_STATE_ERR:
      msg = 'INVALID_STATE_ERR';
      break;
    default:
      msg = 'Unknown Error';
      break;
  };

  console.log('Error: ' + msg);
}

  window.requestFileSystem  = window.requestFileSystem || window.webkitRequestFileSystem;
  window.requestFileSystem(window.PERSISTENT,  100*1024*1024, onInitFs, errorHandler);

  $.image = function(src) {
    return $.Deferred(function(task) {
      var image = new Image();
      image.onload = function() {
        task.resolve(image);
      }
      image.onerror = function() {
        task.reject();
      }
      image.src = src;
    }).promise();
  };
  init_ui();
});