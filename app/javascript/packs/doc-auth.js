function docAuth() {
  const player = document.getElementById('player');
  const canvas = document.getElementById('canvas');
  const context = canvas.getContext('2d');
  const captureButton = document.getElementById('capture');
  const input = document.getElementById('_doc_auth_image');

  const constraints = {
    video: true,
  };

  let state = {
    video: true,
  };

  captureButton.addEventListener('click', () => {
    state.video ? captureImage() : resetImage()
    state.video = !state.video
  });

  startVideo()

  function captureImage() {
    // Draw the video frame to the canvas.
    context.drawImage(player, 0, 0, player.width, player.height);
    input.value = canvas.toDataURL('image/png');
    player.style.display = 'none';
    canvas.style.display = 'inline-block';
    captureButton.innerHTML = 'Reset'
    player.srcObject.getVideoTracks().forEach(track => track.stop());
    player.srcObject = null;
  }

  function resetImage() {
    startVideo()
    canvas.style.display = 'none';
    player.style.display = 'inline-block';
    captureButton.innerHTML = 'Capture'
    input.value ='';
    context.clearRect(0, 0, canvas.width, canvas.height);
  }

  function startVideo() {
    // Attach the video stream to the video element and autoplay.
    navigator.mediaDevices.getUserMedia(constraints)
      .then((stream) => {
        player.srcObject = stream;
      });
  }
}

document.addEventListener('DOMContentLoaded', docAuth)
