(function() {
	var script_tag = jQuery('script[src*="brimir-plugin.js"]');

	function brimir_plugin_init(){

		if(script_tag.data('skip-css') == undefined) {

			var css_url = script_tag.attr('src');
			css_url = css_url.replace('brimir-plugin.js', 'brimir-plugin.css');

			jQuery('head').append('<link href="' + css_url + '" media="screen" rel="stylesheet" />');
		}

		if(script_tag.data('skip-tabs') == undefined) {
			jQuery('body').append(
				'<div class="brimir-plugin-tabs">' +
					'<a href="#" data-brimir-plugin="open">@</a>' +
				'</div>'
			);
		}

		// listeners
		jQuery(document).on('click', '[data-brimir-plugin="open"]', function(e){
			e.preventDefault();
			brimir_plugin_init_popup();

			var form_url = script_tag.attr('src');
			form_url = form_url.replace('assets/brimir-plugin.js', 'tickets/new?a=');

			if(script_tag.data('prefill-email') != undefined) {
				form_url += '&ticket[from]=' + encodeURIComponent(script_tag.data('prefill-email'));
			}
			if(script_tag.data('prefill-subject') != undefined) {
				form_url += '&ticket[subject]=' + encodeURIComponent(script_tag.data('prefill-subject'));
			}

			jQuery.ajax({
				url: form_url,
				success: brimir_plugin_insert_form
			});
			jQuery('.brimir-plugin-popup').addClass('show');
			jQuery('.brimir-plugin-overlay').addClass('show');
		});

		jQuery(document).on('click', '[data-brimir-plugin="close"]', function(e){
			e.preventDefault();
			brimir_plugin_popup_close();
		});

	}

	function brimir_plugin_popup_close() {
		jQuery('.brimir-plugin-popup').removeClass('show');
		jQuery('.brimir-plugin-overlay').removeClass('show');
	}

	function brimir_plugin_insert_form(data) {
		jQuery('.brimir-plugin-popup form').replaceWith(jQuery(data).find('form'));
		jQuery('.brimir-plugin-popup form').on('submit', function(e) {
			e.preventDefault();

			jQuery.ajax({
				url: jQuery(this).attr('action'),
				type: 'post',
				data: jQuery(this).serialize(),
				success: function(data) {
					alert('Ticket created');
					brimir_plugin_popup_close();
				},
				error: brimir_plugin_insert_form
			});
		});
	}

	function brimir_plugin_init_popup() {
		if(jQuery('.brimir-plugin-popup').size() == 0) {
			jQuery('body').append('<div class="brimir-plugin-popup"><form></form><a href="#" data-brimir-plugin="close">&times;</a></div>');

			jQuery('body').prepend('<div class="brimir-plugin-overlay"></div>');
		}
	}

	if(jQuery != undefined) {
		jQuery(document).ready(brimir_plugin_init);
		/* support turbolinks */
		jQuery(document).on('page:load', brimir_plugin_init);
	}

})();
