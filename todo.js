;(function() {
    var form = document.getElementById('todo-form');
    var list = document.getElementById('todo-list');
    var template = document.getElementById('todo-template');

    form.addEventListener('submit', function(event) {
        event.preventDefault();
        addItem(this.elements['todo-item'].value);
        this.reset();
    });

    function addItem(value) {
        var item = template.cloneNode(true);
        item.paragraph = item.getElementsByTagName('p').item(0);
        item.checkbox = item.getElementsByTagName('input').item(0);
        item.id = '';
        item.checkbox.addEventListener('change', handleCheckbox);
        item.paragraph.addEventListener('click', editText);
        item.paragraph.appendChild(document.createTextNode(value));
        list.appendChild(item);
    }

    function editText() {
        var item = this.parentNode;
        item.input = document.createElement('input');
        item.input.value = this.firstChild.nodeValue;
        item.className = 'edit';
        item.appendChild(item.input);
        item.input.addEventListener('change', commitText);
        item.input.addEventListener('blur', commitText);
    }

    function commitText(event) {
        var item = this.parentNode;
        event.stopPropagation();
        item.paragraph.replaceChild(document.createTextNode(this.value),
                                    item.paragraph.firstChild);
        item.className = '';
        setTimeout(function() {
            item.removeChild(item.input);
            item.input = null;
        }, 10);
        
    }

    function handleCheckbox() {
        var item = this.parentNode;
        if (this.checked) {
            item.className = 'done';
            item.timeout = setTimeout(function() {
                removeItem(item);
            }, 10 * 1000);
        } else {
            item.className = '';
            if (item.timeout) {
                clearTimeout(item.timeout);
                item.timeout = null;
            }
        }
    }

    function removeItem(item) {
        list.removeChild(item);
    }
})();
