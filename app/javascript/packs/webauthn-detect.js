const WebAuthn = require('../app/webauthn');

function detectWebauthn() {
  const webauthnOption = document.querySelector('label[for=two_factor_options_form_selection_webauthn]');
  const parentNode = webauthnOption.parentNode;

  PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable().then(function (platformAvailable) {
    // fix this remove exclaimation
    if (!platformAvailable) {

      const currentPlatform = navigator.platform;

      // create a new option if platform is detected
      const detectedOption = webauthnOption.cloneNode(true);

      // add it to the top of the options list
      parentNode.insertBefore(detectedOption, webauthnOption);

      // change id name
      detectedOption.setAttribute('for', 'two_factor_options_form_selection_detected');
      detectedOption.querySelector('input[type=radio]').setAttribute('id', 'two_factor_options_form_selection_detected');

      // change label value
      const optionLabel = detectedOption.getElementsByClassName('green-dark bold fs-20p')[0];
      optionLabel.innerHTML = 'Use your ' + currentPlatform + ' (Recommended)';

      // change info value
      const optionInfo = detectedOption.getElementsByClassName('regular gray-dark fs-10p mt0 mb-tiny')[0];
      optionInfo.innerHTML = 'Use your ' + currentPlatform + ' to secure your account';

      // bye bye webauthn coloring
      webauthnOption.classList.remove('bg-light-green');

    }
  });



  // to uncheck the selection webauthn =>
  // select it by the id two_factor_options_form_selection_webauthn, removeAttribute("checked")

  //webauthnOption.removeAttribute("checked");

}
document.addEventListener('DOMContentLoaded', detectWebauthn);
