pdxGltfSpecificationVersion = "2.0.1";

function pdxModelFile() : pdxException() constructor {
    filename = "";
    filepath = "";
    filebase = "";
    
    static open = function(apath, afile, abase) {
        if(file_exists(apath + afile)) {
            self.filepath = apath;
            self.filename = afile;
            self.filebase = abase;
            return true;            
        }
        return false;
    }
}

function pdxGLTFBase(): pdxModelFile() constructor {
    self.json = "";
    self.load_time = 0;
    self.read_time = 0;

    self.data = undefined;
    
    self.counts = {
        extensionsRequired: 0,
        extensionsUsed: 0,
        scenes: 0,
        nodes: 0,
        materials: 0,
        meshes: 0,
        textures: 0,
        accessors: 0,
        bufferViews: 0,
        samplers: 0,
        buffers: 0,
        animations: 0,
        skins: 0,
        cameras: 0,
        images: 0 
    }
    
    static create_counts = function(json_struct) {
        self.counts.extensionsRequired = array_length(self.extensionsRequired);
        self.counts.extensionsUsed = array_length(self.extensionsUsed);
        self.counts.scenes = array_length(self.scenes);
        self.counts.nodes = array_length(self.nodes);
        self.counts.materials = array_length(self.materials);
        self.counts.meshes = array_length(self.meshes);
        self.counts.textures = array_length(self.textures);
        self.counts.accessors = array_length(self.accessors);
        self.counts.bufferViews = array_length(self.bufferViews);
        self.counts.samplers = array_length(self.samplers);
        self.counts.buffers = array_length(self.buffers);
        self.counts.animations = array_length(self.animations);
        self.counts.skins = array_length(self.skins);
        self.counts.cameras = array_length(self.cameras);
        self.counts.images = array_length(self.images);
        
    }
    
    static load_external_buffers = function() {
        for(var _i = 0; _i < self.counts.buffers; _i++) {
            if(struct_exists(self.buffers[_i], "uri")) {
                if(!file_exists(self.filepath + self.buffers[_i].uri)) {
                    self.critical("Exsternal data buffer bot found : " + self.filepath + self.buffers[_i].uri);
                }
                if(self.buffers[_i].data==undefined) {
                    if(struct_exists(self.buffers[_i], "byteLength")) {
                        self.buffers[_i].data = buffer_create(self.buffers[_i].byteLength, buffer_grow, 1);
                        buffer_load_ext(self.buffers[_i].data, self.filepath + self.buffers[_i].uri, 0);
                        
                    }
                } else {
                    self.add_warning("Buffer #" + string(_i) + " already contains data");
                }
            }
        }
    }
    
    static free = function() {
        /*
        for(var _i = 0; _i < self.counts.images; _i++) {
            self.images[_il].free();
        }
        self.count.images = 0;
        */ 
        for(var _i = 0; _i < self.counts.buffers; _i++) {
            if(buffer_exists(self.buffers[_i].data)) {
                buffer_delete(self.buffers[_i].data);
                self.buffers[_i].data = undefined;
            }
        }
        self.counts.buffers = 0;
    }
    
    static build = function() {
        /*
        if(typeof(self.scene)=="number") {
            if(!struct_exists(self, "scenes")) {
                return false;
            }
            if(!struct_exists(self, "nodes")) {
                return false;
            } 

            if(self.scene < self.counts.scenes) {
                var _scene = self.scenes[self.scene];
                if(!struct_exists(_scene, "nodes")) {
                    return false;
                }
                var _scene_nodes = array_length(_scene.nodes);
                for(var _n = 0; _n<_scene_nodes; _n++) {
                    var _node_index = _scene.nodes[_n];
                    if(_node_index < self.counts.nodes) {
                        var _node = self.nodes[_node_index];
                        self.process_node(_node);
                    }
                }
            }
        }
         */
    }

}

function pdxGLTF(): pdxGLTFBase() constructor {
    static read = function() {
        self.load_time = get_timer();
        var _buffer = buffer_create(0, buffer_grow, 1);
        if(_buffer == -1) {
            throw("Can't create buffer");
        }
        buffer_load_ext(_buffer, self.filepath + self.filename, 0);
        var _bsize = buffer_get_size(_buffer);
        self.read_time = get_timer() - self.load_time;
        if(_bsize > 0) {
            var _json_txt = buffer_read(_buffer, buffer_string);
            self.json = json_parse(_json_txt);
            
            self.data = new pdxGltfData();
            self.data.init(self.json);
        }
        buffer_delete(_buffer);
        
        self.load_external_buffers();
    }
} 

function pdxGLB(): pdxGLTFBase() constructor {
    self.bufcount = 0;
    self.binbuffers = array_create(1);
    
    static read = function() {
        self.load_time = get_timer();
        var _buffer = buffer_create(0, buffer_grow, 1);
        if(_buffer == -1) {
            throw("Can't create buffer");
        }
        buffer_load_ext(_buffer, self.filepath + self.filename, 0);
        var _bsize = buffer_get_size(_buffer);
        self.read_time = get_timer() - self.load_time;
        if(_bsize > 12) {
            var _magic = buffer_read(_buffer, buffer_u32);
            var _version = buffer_read(_buffer, buffer_u32); 
            var _length = buffer_read(_buffer, buffer_u32);
            if(_magic <> 0x46546C67) {
                self.add_error("glTF magic wrong");
                return false;
            }
            if(_version <> 2) {
                self.add_error("glTF version wrong");
                return false;
            }
            if(_length <> _bsize) {
                self.add_error("glTF length wrong");
                return false;
            }
            
            while((buffer_tell(_buffer) + 8) < _bsize) {
                var _chunk_length = buffer_read(_buffer, buffer_u32);
                var _chunk_type = buffer_read(_buffer, buffer_u32);
                if((buffer_tell(_buffer) + _chunk_length) > _bsize) {
                    self.add_error("glTF buffer read overflow");
                    return false;
                }
                switch(_chunk_type) {
                    case gltfChunk.JSON:
                        var _tempbuf1 = buffer_create(_chunk_length, buffer_fixed, 1);
                        buffer_copy(_buffer, buffer_tell(_buffer), _chunk_length, _tempbuf1, 0);
                        var _json_txt = buffer_read(_tempbuf1, buffer_string);
                        self.json = json_parse(_json_txt);
                        
                        self.data = new pdxGltfData();
                        self.data.init(self.json);

                        var _outfile = self.filepath + self.filebase + ".json";
                        if(!file_exists(_outfile)) {
                            buffer_save_ext(_tempbuf1, _outfile, 0, _chunk_length);
                        }
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        buffer_delete(_tempbuf1);
                        
                        break;
                    case gltfChunk.BIN:
                        self.bufcount++;
                        if(self.bufcount <> 1) {
                            self.critical("GLB has multiple buffer entries");
                        }
                        self.binbuffers[0] = buffer_create(_chunk_length, buffer_fixed, 1);
                        buffer_copy(_buffer, buffer_tell(_buffer), _chunk_length, self.binbuffers[0], 0);
                        // Do stuff with tempobuf2
                        if(self.filename == "world.glb") {
                            var _al = array_length(self.images);
                            array_resize(self.images, _al + 1)
                            self.images[_al] = new pdxImage();
                            self.images[_al].load_from_buffer(self.binbuffers[0], 69248, 1337486, "tex_world");
                        }
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        break;
                    default:
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        self.critical("Unhandled Binary Chunk");
                        break;
                }
            }
            
        }
        buffer_delete(_buffer);
        
        self.load_external_buffers();
        
        self.load_time = get_timer() - self.load_time;

        return true;
    }
    
}

