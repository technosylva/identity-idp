function docAuth() {
  const player = document.getElementById('player');
  const canvas = document.getElementById('canvas');
  const context = canvas.getContext('2d');
  const captureButton = document.getElementById('capture');
  const input = document.getElementById('_doc_auth_image');

  const constraints = {
    video: true,
  };

  captureButton.addEventListener('click', () => {
    // Draw the video frame to the canvas.
    context.drawImage(player, 0, 0, canvas.width, canvas.height);
    input.value = canvas.toDataURL('image/png');
    player.srcObject.getVideoTracks().forEach(track => track.stop());
  });

  // Attach the video stream to the video element and autoplay.
  navigator.mediaDevices.getUserMedia(constraints)
    .then((stream) => {
      player.srcObject = stream;
    });
  }


document.addEventListener('DOMContentLoaded', docAuth)
