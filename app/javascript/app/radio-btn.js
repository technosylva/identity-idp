import 'classlist.js';

function clearHighlight(name) {
  var radioGroup = document.querySelectorAll(`input[name='${name}']`);

  Array.prototype.forEach.call(radioGroup, (radio) => {
    radio.parentNode.parentNode.classList.remove('bg-lightest-blue', 'bg-light-green');
  });
}

function highlightRadioBtn() {
  var radiosDefault = document.querySelectorAll('.btn-border input[type=radio]');
  var radiosGreen = document.querySelectorAll('.btn-border-green input[type=radio]');

  if (radiosDefault) {
    Array.prototype.forEach.call(radiosDefault, (radio) => {
      const label = radio.parentNode.parentNode;
      const name = radio.getAttribute('name');

      if (radio.checked) label.classList.add('bg-lightest-blue');

      radio.addEventListener('change', function() {
        clearHighlight(name);
        if (radio.checked) label.classList.add('bg-lightest-blue');
      });

      radio.addEventListener('focus', function() {
        const autofocusedInput = label.querySelector('input.auto-focus');
        label.classList.add('is-focused');
        if (autofocusedInput) { autofocusedInput.focus(); }
      });

      radio.addEventListener('blur', function() {
        label.classList.remove('is-focused');
      });
    });


  }

  if (radiosGreen) {
    Array.prototype.forEach.call(radiosGreen, (radio) => {
      const label = radio.parentNode.parentNode;
      const name = radio.getAttribute('name');

      if (radio.checked) label.classList.add('bg-light-green');

      radio.addEventListener('change', function() {
        clearHighlight(name);
        if (radio.checked) label.classList.add('bg-light-green');
      });

      radio.addEventListener('focus', function() {
        const autofocusedInput = label.querySelector('input.auto-focus');
        label.classList.add('is-focused');
        if (autofocusedInput) { autofocusedInput.focus(); }
      });

      radio.addEventListener('blur', function() {
        label.classList.remove('is-focused');
      });
    });
  }
}

document.addEventListener('DOMContentLoaded', highlightRadioBtn);

export {
  highlightRadioBtn,
};
