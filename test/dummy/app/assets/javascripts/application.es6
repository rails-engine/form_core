//= require rails-ujs
//= require turbolinks
//= require jquery3

//= require selectize
//= require cocoon
//= require activestorage
//= require direct_uploads

// Cheat form https://github.com/jgthms/bulma/blob/master/docs/_javascript/main.js
document.addEventListener('DOMContentLoaded', () => {

  // Dropdowns

  const $dropdowns = getAll('.dropdown:not(.is-hoverable)');

  if ($dropdowns.length > 0) {
    $dropdowns.forEach($el => {
      $el.addEventListener('click', event => {
        event.stopPropagation();
        $el.classList.toggle('is-active');
      });
    });

    document.addEventListener('click', event => {
      closeDropdowns();
    });
  }

  function closeDropdowns() {
    $dropdowns.forEach($el => {
      $el.classList.remove('is-active');
    });
  }

  // Functions

  function getAll(selector) {
    return Array.prototype.slice.call(document.querySelectorAll(selector), 0);
  }

  // Utils

  function removeFromArray(array, value) {
    if (array.includes(value)) {
      const value_index = array.indexOf(value);
      array.splice(value_index, 1);
    }

    return array;
  }

  Array.prototype.diff = function (a) {
    return this.filter(function (i) {
      return a.indexOf(i) < 0;
    });
  };
});
