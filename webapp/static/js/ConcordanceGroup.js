$(window).on('load', function() {
    var toc = $('#toc');
    var anchors = $('.toc');
    var ul = document.createElement('html:ul');
    toc.append(ul);
    function forEachFunction (anchor, index) {
        anchor.setAttribute('html:name', 'index' + index);

        var link = document.createElement('html:a');
        link.setAttribute('html:href', '#index' + index);
        link.textContent = anchor.parentNode.textContent;

        var li = document.createElement('html:li');
        li.setAttribute('class', anchor.parentNode.tagName.toLowerCase());

        li.append(link);
        ul.append(li);
    }
    Array.from(anchors).forEach(forEachFunction, ul);
});