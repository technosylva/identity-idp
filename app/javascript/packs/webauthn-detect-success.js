const WebAuthn = require('../app/webauthn');

function editSuccessWebauthnPage() {
  PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable().then(function (platformAvailable) {
    // FIXME remove exclaimation
    if (!platformAvailable) {

      //const currentPlatform = navigator.platform;
      const currentPlatform = "Yubico security key";

      // get all the content that needs to be changed
      const detectedTitle = document.getElementsByClassName('h3 mb2 mt3 my0')[0];
      const detectedDescription = document.querySelector('p');

      // change the content
      detectedTitle.innerHTML = 'You have added ' + currentPlatform + ' as your authentication method.';
      detectedDescription.innerHTML = 'Each time you sign into login.gov, we will ask you to use '
      + currentPlatform + '. If you sign in from a different device, you can use any other '
      + 'authentication methods you have enabled.';
    }
  });
}

document.addEventListener('DOMContentLoaded', editSuccessWebauthnPage);
