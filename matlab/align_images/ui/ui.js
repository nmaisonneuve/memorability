function images_loaded(image1, image2) {
  img1 = image1;
  img2 = image2;
  canvas.width = img1.width;
  canvas.height = img2.height;

  // if canvas dims != image dims 
  // we assume width x height img1 = width x height  img2
  /*ratio_img = {
  width: img1.width / canvas.width,
  height: img1.height / canvas.height
};*/

  drawing(0.4);
}

function drawing(opacity_level) {
  if (opacity_level == undefined) {
    opacity_level = $("#slider1").slider("option", "value") / 100.0;
  }
  ctx.globalAlpha = 1;
  ctx.drawImage(img1, 0, 0);
  if (opacity_level > 0) {
    ctx.globalAlpha = opacity_level;
    ctx.drawImage(img2, 0, 0);
  }
}

function print_nb_clicks() {
  if (nb_points == 0) {
    $("#msg").html("Click on 3 points in image 1 (left side of the slider)");
  } else if (nb_points == 3) {
    $("#msg").html("Now click on the same 3 points in image 2 (right side of the slider)");
  } else {
    $("#msg").html(nb_points + " click(s)");
  }
};

function init_ui() {
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

  // UI
  slider = $("#slider1").slider({
    value: 40,
    min: 0,
    max: 100,
    step: 20,
    slide: function(event, ui) {
      drawing(ui.value / 100.0)
    }
  });
  canvas = document.getElementById("before_canvas");
  ctx = canvas.getContext("2d");
  ctx.globalCompositeOperation = "source-over";
  $("#before_canvas").on('click', clicking);
  $("#next").on('click', next_pair);
  $("#export").on('click', export_alignments);
}