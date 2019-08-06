const WebAuthn = require('../app/webauthn');
const highlightRadioBtn = require('../app/radio-btn').highlightRadioBtn;

function detectWebauthn() {
  const webauthnOption = document.querySelector('label[for=two_factor_options_form_selection_webauthn]');
  const parentNode = webauthnOption.parentNode;

  // might have to be window.PublicKeyCredential?? check js/app/platform-authenticator.js
  PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable().then(function (platformAvailable) {
    // FIXME remove exclaimation
    if (!platformAvailable) {

      // const currentPlatform = navigator.platform;
      // currently hardcoded for prototype readability
      const currentPlatform = "Windows Hello";

      // create a new radio button option if platform is detected
      const detectedOption = webauthnOption.cloneNode(true);

      // add it to the top of the options list (above security key)
      parentNode.insertBefore(detectedOption, webauthnOption);

      // calling this again otherwise the new radio button is not recognized
      highlightRadioBtn();

      // change identifiers for new detected option radio button
      detectedOption.setAttribute('for', 'two_factor_options_form_selection_detected');
      detectedOption.querySelector('input[type=radio]').setAttribute('id', 'two_factor_options_form_selection_detected');
      detectedOption.querySelector('input[type=radio]').setAttribute('value', 'detected');

      // change label value
      const optionLabel = detectedOption.getElementsByClassName('blue bold fs-20p')[0];
      optionLabel.innerHTML = currentPlatform;

      // change more info value
      const optionInfo = detectedOption.getElementsByClassName('regular gray-dark fs-10p mt0 mb-tiny')[0];
      optionInfo.innerHTML = 'Use your ' + currentPlatform;

      // change tooltip value
      const optionTooltip = detectedOption.getElementsByClassName('hint--right hint--no-animate')[0];

      optionTooltip.setAttribute('aria-label',
        'Recommended because it is one of the most secure options and '
        + 'we noticed that it is available on your device.');

      // remove highlight from the webauthn option bc we want to highlight detected option
      webauthnOption.classList.remove('bg-lightest-blue');
    }
  });
}

document.addEventListener('DOMContentLoaded', detectWebauthn);
