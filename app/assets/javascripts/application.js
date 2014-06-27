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
//= require_tree .

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

    var screenY = jQuery(document).outerHeight();
    jQuery('aside').css('min-height', screenY+'px');

    jQuery('#ticket_assignee_id, #ticket_priority_id, #ticket_status_id').select2({ width: 'resolve' });

    dialog = jQuery('[data-dialog]');

    jQuery('[data-modal-form]').click(function(e) {

      e.preventDefault();

      // load the form through ajax
      jQuery.ajax({
        url: jQuery(this).attr('href'),
        success: insertFormInDialog
      });

    });

    jQuery('#reply_to, #reply_cc, #reply_bcc').select2({
        width: 'resolve',
        createSearchChoice:function(term, data) {
            if (jQuery(data).filter(function() {
                return this.text.localeCompare(term)===0; }).length===0) {
                    return {id:term, text:term};
                }
            },
        multiple: true,
        minimumInputLength: 3,
        ajax: {
          url: "/users.json",
          dataType: 'json',
          data: function (term, page) {
            return {
              q: term
            };
          },
          results: function (data) {
            return { results: data.users };
          }
        },
        initSelection: function(element, callback) {
          var id = jQuery(element).val();
          if (id !== "") {
            jQuery.ajax('/users.json', {
              data: {
                init: true,
                q: id
              },
              dataType: "json"
            }).done(function(data) { 
              callback(data.users); 
            });
          }
        },
    });

    tinyMCE.init({
      autoresize_bottom_margin: 0,
      selector: "textarea.tinymce",
      statusbar: false,
      menubar: false,
      toolbar: "undo redo | bold italic | bullist numlist | outdent indent removeformat",
        height: 150
    });

    jQuery(document).foundation();

  });


})();
