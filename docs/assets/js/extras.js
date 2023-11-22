var splash_video = {
  setup: function() {
    document.querySelector('#splash-video').playbackRate = 0.5;
  }
};

$(document).ready(function() {
  splash_video.setup();
});