const WebAuthn = require('../app/webauthn');

function editDefaultWebauthnPage() {
  PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable().then(function (platformAvailable) {
    // FIXME remove exclaimation
    if (!platformAvailable) {

      //const currentPlatform = navigator.platform;
      const currentPlatform = "Yubico security key";

      // get all the content that needs to be changed
      const detectedTitle = document.getElementsByClassName('h3 my0')[0];
      const detectedDescription = document.getElementsByClassName('mt-tiny mb3')[0];
      const detectedFormName = document.querySelector('label[for=code]');
      // const securityKeyImg = document.querySelector('img[alt="Security key"]');

      // change the content
      detectedTitle.innerHTML = 'Add your ' + currentPlatform;
      detectedDescription.innerHTML = 'The ' + currentPlatform + ' connected to your device is'
      + ' a security key that supports FIDO standards. Add it as an authentication method to'
      + ' your account.';
      detectedFormName.innerHTML = 'Authenticator nickname';

      // delete the security key image?
      // securityKeyImg.parentNode.removeChild(securityKeyImg);
    }
  });
}

document.addEventListener('DOMContentLoaded', editDefaultWebauthnPage);
