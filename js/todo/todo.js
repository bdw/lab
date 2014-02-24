;(function() {
    var list = document.getElementById('todo');
    var template = document.getElementById('template');
    var input = document.getElementById('add');

    input.addEventListener('change', function() {
        addItem(this.value);
        this.value = '';
    });

    function addItem(value) {
        var item = template.cloneNode(true);
        item.checkbox = item.children[0];
        item.paragraph = item.children[1];
        item.input = item.children[2];
        item.id = '';
        item.input.id = '';
        item.className = 'todo';
        item.paragraph.appendChild(document.createTextNode(value));
        item.checkbox.addEventListener('change', handleCheckbox);
        item.paragraph.addEventListener('click', editText);
        item.input.addEventListener('change', commitText);
        item.input.addEventListener('blur', commitText);
        list.appendChild(item);
    }

    function editText() {
        var item = this.parentNode;
        item.className = 'edit';
        item.input.value = this.firstChild.nodeValue;
        item.input.focus();
    }

    function commitText(event) {
        var item = this.parentNode;
        item.paragraph.replaceChild(document.createTextNode(this.value),
                                    item.paragraph.firstChild);
        item.input.blur();
        item.className = 'todo';
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
