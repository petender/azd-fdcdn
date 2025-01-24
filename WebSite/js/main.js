(function($) {
    
    var buttons = $('.button').on('click', function(e) {
        e.preventDefault();
        var $this = $(this),
            list = $this.parent().find('ul'),
            results = $this.parent().find('.results'),
            entryUrl = $this.data('entryUrl'),
            totalTime = 0;
        
        list.empty();
        var now = new Date().getTime();
        for(var i = 1; i <= 6; i++) {
            var img = $('<img src="' + entryUrl +  '/image-0' + i +'.jpg" class="image" />');
            img.on('load', function() {
                totalTime += new Date().getTime() - now;
                results.text('Loading time: ' + totalTime + ' ms');
            });
            list.append($('<li />').append(img));            
        } 

        results.text('Loading time: calculating...');
    });    


})(jQuery);