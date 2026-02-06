function pdxWidget() : pdxException() constructor {

}

function pdxWidgetTreeVieewPair(key, value) : pdxWidget() constructor {
    self.key = key;
    self.value = value;
    
}

function pdxWidgetTreeVieewItem(title, depth = 0) : pdxWidget() constructor {
    self.name = title;
    self.depth = depth;
    self.items = [];
    
    static addItem = function(key, value) {
        var newItem = new pdxWidgetTreeVieewPair(key, value);
        array_push(self.items, newItem);
        
        return newItem;
    }
    
    static addNode = function(title) {
        var newNode = new pdxWidgetTreeVieewItem(title, self.depth + 1);
        var newItem = new pdxWidgetTreeVieewPair(title, newNode);
        array_push(self.items, newItem);
        
        return newNode;
    }
    
    static prettyPrint = function() {
        txt = "[" + string(self.depth) + "]" + string_repeat(" ", self.depth * TABSIZE) + self.name + "\n";
        for(var _i=0, _n = array_length(self.items); _i<_n; _i++) {
            var _val = self.items[_i].value;
            if(typeof(_val) == "struct") {
                if(is_instanceof(_val, pdxWidgetTreeVieewItem)) {
                    txt += _val.prettyPrint();
                } else {
                    txt += string(_val) + "\n";
                }
            } else {
                txt += "[" + string(self.depth) + "]" + string_repeat(" ", (self.depth + 1) * TABSIZE) + self.items[_i].key + " = " + self.items[_i].value + "\n";
            }
            
        }
        return txt;
    }
}

function pdxWidgetTreeView(title) : pdxWidget() constructor {
    self.rootNode = new pdxWidgetTreeVieewItem(title);
    
    static getRoot = function() {
        return self.rootNode;
    }
    
    static prettyPrint = function() {
        return self.rootNode.prettyPrint();
    }

}

