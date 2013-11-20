/* FeedEk jQuery RSS/ATOM Feed Plugin v1.1.2
*  http://jquery-plugins.net/FeedEk/FeedEk.html
*  Author : Engin KIZIL http://www.enginkizil.com
*  http://opensource.org/licenses/mit-license.php  
*/

(function ($) {
    $.fn.FeedEk = function (opt) {
        var def = $.extend({
            FeedUrl: "http://rss.cnn.com/rss/edition.rss",
            MaxCount: 5,
            ShowDesc: true,
            ShowPubDate: true,
            CharacterLimit: 0,
            TitleLinkTarget: "_blank"
        }, opt);

        var id = $(this).attr("id");
        var i;
        $.ajax({
            url: "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=" + def.MaxCount + "&output=json&q=" + encodeURIComponent(def.FeedUrl) + "&hl=en&callback=?",
            dataType: "json",
            success: function (data) {
                $("#" + id).empty();
                var s = "";
                var monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
                $.each(data.responseData.feed.entries, function (e, item) {
                    if (def.ShowPubDate) {
                        i = new Date(item.publishedDate);
                        s += i.getDate() + " " + monthNames[i.getMonth()] + ", " + i.getFullYear() + " ";
                    }
                    s += '<a href="' + item.link + '" target="' + def.TitleLinkTarget + '" >' + item.title + "&raquo;</a>";
                    if (def.ShowDesc) {
                        if (def.DescCharacterLimit > 0 && item.content.length > def.DescCharacterLimit) {
                            s += '<div class="itemContent">' + item.content.substr(0, def.DescCharacterLimit) + "...</div>";
                        }
                        else {
                            s += '<div class="itemContent">' + item.content + "</div>";
                        }
                    }
                });
                $("#" + id).append(s);
            }
        });
    };
})(jQuery);
