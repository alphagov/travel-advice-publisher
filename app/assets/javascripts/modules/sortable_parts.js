(function(Modules) {
  "use strict";

  Modules.SortableParts = function() {
    var that = this;
    that.start = function(element) {

      var sortHandleSelector = ".js-sort-handle";

      // jQuery UI sortable options
      // http://api.jqueryui.com/sortable/
      var sortable_opts = {
        axis: "y",
        handle: sortHandleSelector,
        stop: function(event, ui) {
          updateInputOrder();
          highlightMovedPart(ui.item);
        }
      };

      element.sortable(sortable_opts);
      element.find(sortHandleSelector).css({cursor: 'move'});

      function updateInputOrder() {
        element.find('.part').each(function (i, part) {
          $(part).find('input.order').val(i + 1);
        });
      }

      function highlightMovedPart(part) {
        part.find(sortHandleSelector).addClass("yellow-fade");
      }
    };
  };
})(window.GOVUKAdmin.Modules);
