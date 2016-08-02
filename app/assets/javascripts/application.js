// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require select2
//= require tinymce-jquery
//= require tickets
//= require fancybox

(function() {

  var dialog;

  function onsubmit(e) {
    e.preventDefault();

    var form = jQuery(this);

    jQuery.ajax({
      url: form.attr('action'),
      type: 'post',
      data: form.serialize(),
      success: function(data) {

        /* alert found, probably something wrong */
        if(jQuery(data).find('.error').length > 0) {
          insertFormInDialog(data);
        } else {
          document.location.reload();
        }
      }
    });

  }

  function oncancel(e) {
    e.preventDefault();

    jQuery(this).parents('.reveal-modal').foundation('reveal', 'close');
  }

  function insertFormInDialog(data) {

    /* insert the result into the dialog */
    dialog.find('article').html(jQuery(data).find('[data-content]'));

    dialog.find('form').on('submit', onsubmit);

    dialog.find('[data-close-modal]').on('click', oncancel);

    /* show the dialog */
    dialog.foundation('reveal','open');
  }

  jQuery(function() {

    jQuery("a.fancybox").fancybox({
      type : 'image',
      helpers: {
        overlay: {
          locked: false
        }
      }
    });

    if(jQuery('[data-main]').length > 0){
      var page = jQuery(document).height();
      var offset = jQuery('[data-main]').offset().top;
      var height = page - offset;

      jQuery('[data-main]').css('min-height', height+'px');
    }

    jQuery('.select2').select2({ width: 'resolve' });

    dialog = jQuery('[data-dialog]');

    jQuery('[data-modal-form]').click(function(e) {

      e.preventDefault();

      // load the form through ajax
      jQuery.ajax({
        url: jQuery(this).attr('href'),
        success: insertFormInDialog
      });

    });

    tinyMCE.init({
      autoresize_bottom_margin: 0,
      selector: 'textarea.tinymce',
      statusbar: false,
      menubar: false,
      toolbar: 'undo redo | bold italic | bullist numlist | outdent indent removeformat',
      height: 150,
      plugins: 'autoresize,paste',
    });

    jQuery(document).foundation();

  });


})();
