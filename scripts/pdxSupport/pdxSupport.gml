pdxLastImageIndex = 0;
pdxImageIndexDigits = 3;
pdxThrowNotReturn = true;
pdxGlobalGltfErrorFlag = false;
pdxGlobalGltfWarningFlag = false;

function nextsequence(path, base, ext, digits = 3) {
    var _i = 0
    path = string_trim(path);
    base = string_trim(base);
    ext = string_trim(ext);
    while(string_ends_with(path, "/") || string_ends_with(path, "\\")) {
        path = string_copy(path, 1, string_length(path) - 1);
    }
    var seq_file;
    do {   
        _i++;
        var seq = string(_i);
        seq_file = path + "/" + base + string_repeat("0", digits - string_length(seq)) + seq + "." + ext;
    } until(!file_exists(seq_file));
    show_debug_message("Saving " + seq_file);

    return seq_file;
}

function ErrorStruct() constructor {
    static add_error = function(errmsg) {
        if(global.pdxThrowNotReturn) {
            throw(errmsg);                
        }        
        if(!struct_exists(self, "error")) {
            self.error = "";
            global.pdxGlobalGltfErrorFlag = true;
        }
        self.error += string(errmsg) + "\n";
    }
    
    static add_warning = function(errmsg) {
        if(!struct_exists(self, "error")) {
            self.warning = "";
            global.pdxGlobalGltfWarningFlag = true;
        }
        self.warning += string(errmsg) + "\n";
    }
    
    static critical = function(errmsg) {
        throw(errmsg);                
    }
    
    static has_errors = function() {
        if(struct_exists(self, "error")) {
            return true;
        }
       return false;
    }
}

function pdxImageDimensions(width = 0, height = 0) constructor {
    self.width = width;
    self.height = height;
}

function pdxImage() : ErrorStruct() constructor {
    self.buffer = undefined;
    self.texturegroup_name = undefined;
    self.sprite_name = undefined;
    self.sprite_size = new pdxImageDimensions(1024, 1024);
    
    static free = function() {
        if(buffer_exists(self.texturegroup_name)) {
            texturegroup_unload(self.texturegroup_name);
        }
        if(buffer_exists(self.buffer)) {
            buffer_delete(self.buffer);
            self.buffers = undefined;
        }
    }
    
    static load_from_buffer = function(inbuf, buffer_offset, buffer_length, texturegoup) {
        // Before we do anything check the buffer is a buffer and it has spave for the image to read
        if(!buffer_exists(inbuf)) {
            self.add_error("Buffer down not exist");
            return false;    
        }
        if( buffer_get_size(inbuf) < (buffer_offset + buffer_length) ) {
            self.add_error("Buffer is too small");
            return false;
        }
        global.pdxLastImageIndex++;
        var seq = string(global.pdxLastImageIndex);
        self.sprite_name = "img-" + string_repeat("0", global.pdxImageIndexDigits - string_length(seq)) + seq;
        
        self.buffer = buffer_create(buffer_length, buffer_fixed, 1);
        if(self.buffer == -1) {
            self.add_error("Unknown Buffer error");
            return false;
        }
        
        buffer_copy(inbuf, buffer_offset, buffer_length, self.buffer, 0);
        var _sprite_data = { sprites : {}};
        _sprite_data.sprites[$ self.sprite_name] = { width : self.sprite_size.width, height : self.sprite_size.height, frames : [  { x : 0, y : 0 } ] };
        self.texturegroup_name = texturegoup;
        texturegroup_add(self.texturegroup_name, self.buffer, _sprite_data);
        texturegroup_load(self.texturegroup_name);
        
        return true;
    }

}

function get_file_parts(filename, delim = "/") {
    var rval = false;
    var parts = {
        path: "",
        name: "",
        extension: ""
    };
        
    if(file_exists(filename)) {
        var _trailing_path_count = 0;
        if(string_ends_with(filename, "/") || string_ends_with(filename, "\\")) {
            _trailing_path_count = 1;
        }
        var _full_file_parts = string_split_ext(string_trim(filename), ["/","\\"], true);
        var _ffp_count = array_length(_full_file_parts);
        if(_ffp_count > 0) {
            for(var _i = 0; _i < (_ffp_count + _trailing_path_count - 1); _i++) {
                parts.path += _full_file_parts[_i] + delim;
            }
            if(_trailing_path_count == 0) {
                parts.name = string_trim(_full_file_parts[_ffp_count - 1]);    
            }
            
            var _file_parts = string_split(string_trim(_full_file_parts[_ffp_count - 1]), ".", true);
            var _fp_count = array_length(_file_parts);
            if(_fp_count > 1) {
                parts.extension = string_lower(_file_parts[_fp_count - 1]);
            }
        rval = parts;        
        }
    }
    
    return rval;
}

function open_model(filename) {
    var _rval = false;
    var _amodel = undefined;
    var _parts = get_file_parts(filename);
        
    if(_parts && _parts.extension!="") {
        if(_parts.extension == "glb") {
            _amodel = new pdxGLB();
            if(_amodel.open(_parts.path, _parts.name)) {
                _rval = _amodel;
            } else {
                delete(_amodel);
            }
        } else if(_parts.extension == "gltf") {
            _amodel = new pdxGLTF();
            if(_amodel.open(_parts.path, _parts.name)) {
                _rval = _amodel;
            } else {
                delete(_amodel);
            }
        }
    }

    
    return _rval;
}