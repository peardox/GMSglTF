pdxLastImageIndex = 0;
pdxImageIndexDigits = 3;
pdxThrowNotReturn = true;

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
        }
        self.error += string(errmsg) + "\n";
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
        texturegroup_add(texturegoup, self.buffer, _sprite_data);
        texturegroup_load(texturegoup);
        
        return true;
    }

}