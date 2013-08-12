var img1, img2, ctx, canvas;
//var ratio_img;
nb_points = 0;
from_pts = [];
to_pts = [];
pair_idx = -1;
saved_pairs = [];


//example of list of pairs (could be imported from pairwise.csv)
var pairs = [
  ["im2_before.jpg", "im2_after.jpg"],
  ["im3_before.jpg", "im3_after.jpg"]
];

function next_pair() {
  next_pair_idx = pair_idx + 1;
  if (next_pair_idx < pairs.length) {
    load_pair(next_pair_idx);
  } else {
    $("#msg").html("all pairs have been aligned, export the result");
  }
}

function load_pair(i) {
  pair_idx = i;
  nb_points = 0;
  from_pts = [];
  to_pts = [];
  print_nb_clicks();
  console.log("loading pair " + i);
  img1_filename = pairs[i][0];
  img2_filename = pairs[i][1];
  $.when($.image(img1_filename), $.image(img2_filename)).done(images_loaded);
}

function export_alignments() {
  var string = JSON.stringify(saved_pairs);
  var bb = new Blob([string], {
    type: 'text/plain'
  });
  $("#export")[0].href = window.URL.createObjectURL(bb);
}

function save_alignment() {
  filename = pairs[pair_idx][0];
  saved_pairs.push({
    from_pts: from_pts,
    to_pts: to_pts,
    imagepath: filename,
    outputpath: filename.replace(".jpg", "_aligned.jpg")
  });
}

function clicking(e) {
  if (nb_points < 3)
    from_pts.push(get_point(e));
  else
    to_pts.push(get_point(e));
  nb_points += 1;
  print_nb_clicks();
  if (nb_points == 6) {
    save_alignment();
    next_pair();
  };
};

function get_point(event) {
  var point = [
    event.pageX - $(canvas).offset().left,
    event.pageY - $(canvas).offset().top
  ];
  return point;
  /* if canvas dims != image dims
  return {
    x: point.x * ratio_img.width , 
    y: point.y * ratio_img.height
  }; */
}

$(function() {
  init_ui();
  //load 1rst pair
  next_pair();
});