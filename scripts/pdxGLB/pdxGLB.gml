#macro TABSIZE 4
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
    self.errval = false;

    self.data = undefined;
    self.tree = "";
    
    self.counts = {
        asset: 0,
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
    
    static get_count = function(object, element) {
        if(is_array(object[$ element])) {
            return array_length(object[$ element]);
        } else {
            return 0;
        }
    }
    static create_counts = function() {
        self.counts.asset =              self.get_count(self.data, "asset");
        self.counts.extensionsRequired = self.get_count(self.data, "extensionsRequired");
        self.counts.extensionsUsed =     self.get_count(self.data, "extensionsUsed");
        self.counts.scenes =             self.get_count(self.data, "scenes");
        self.counts.nodes =              self.get_count(self.data, "nodes");
        self.counts.materials =          self.get_count(self.data, "materials");
        self.counts.meshes =             self.get_count(self.data, "meshes");
        self.counts.textures =           self.get_count(self.data, "textures");
        self.counts.accessors =          self.get_count(self.data, "accessors");
        self.counts.bufferViews =        self.get_count(self.data, "bufferViews");
        self.counts.samplers =           self.get_count(self.data, "samplers");
        self.counts.buffers =            self.get_count(self.data, "buffers");
        self.counts.animations =         self.get_count(self.data, "animations");
        self.counts.skins =              self.get_count(self.data, "skins");
        self.counts.cameras =            self.get_count(self.data, "cameras");
        self.counts.images =             self.get_count(self.data, "images");
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
    }
    
    static gather_errors = function() {
        self.errval = false;
        var text = "Assets\n\n";        
        var ec = 0;     
        if(self.data.asset.has_errors()) {
            text += self.data.asset.error;
            ec++;
            self.errval = false;
        } else {
            text += "No errors\n";
        }
    
        text += "\nScenes (" + string(self.counts.scenes) + ")\n\n";   
        ec = 0;     
        for(var _i =0; _i < self.counts.scenes; _i++) {
            if(self.data.scenes[_i].has_errors()) {
                text += self.data.scenes[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nNodes (" + string(self.counts.nodes) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.nodes; _i++) {
            if(self.data.nodes[_i].has_errors()) {
                text += self.data.nodes[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nMaterials (" + string(self.counts.materials) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.materials; _i++) {
            if(self.data.materials[_i].has_errors()) {
                text += self.data.materials[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nMeshes (" + string(self.counts.meshes) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.meshes; _i++) {
            if(self.data.meshes[_i].has_errors()) {
                text += self.data.meshes[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nImages (" + string(self.counts.images) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.images; _i++) {
            if(self.data.images[_i].has_errors()) {
                text += self.data.images[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nAccessors (" + string(self.counts.accessors) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.accessors; _i++) {
            if(self.data.accessors[_i].has_errors()) {
                text += self.data.accessors[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        text += "\nBufferViews (" + string(self.counts.bufferViews) + ")\n\n";
        ec = 0;     
        for(var _i =0; _i < self.counts.bufferViews; _i++) {
            if(self.data.bufferViews[_i].has_errors()) {
                text += self.data.bufferViews[_i].error;
                ec++;
                self.errval = false;
            }
        }
        if(ec == 0) {
            text += "No errors\n";
        }
        
        return text;
    }
    
    static add_tree = function(txt) {
        self.tree += txt;
    }
    static struct_has = function(object, key) {
        if(struct_exists(object, key)) {
            if(is_undefined(object[$ key])) {
                return false;
            } else {
                return true;
            }
        }
        
        return false;
    }
    
    static process_attributes = function(attributes, depth = 0) {
        if(struct_has(attributes, "POSITION")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "POSITION : " + string(attributes.POSITION) + "\n");
        }
        if(struct_has(attributes, "NORMAL")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "NORMAL   : " + string(attributes.NORMAL) + "\n");
        }
        if(struct_has(attributes, "TANGENT")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "TANGENT  : " + string(attributes.TANGENT) + "\n");
        }
        if(struct_has(attributes, "texcoord")) {
            var _al = array_length(attributes.texcoord);
            for(var _i=0; _i< _al; _i++) {
                self.add_tree(string_repeat(" ", depth * TABSIZE) + "TEXCOORD_" + string(_i) + " : " + string(attributes.texcoord[_i]) + "\n");
            }
        }
        if(struct_has(attributes, "color")) {
            var _al = array_length(attributes.texcoord);
            for(var _i=0; _i< _al; _i++) {
                self.add_tree(string_repeat(" ", depth * TABSIZE) + "COLOR_" + string(_i) + " : " + string(attributes.color[_i]) + "\n");
            }
        }
        if(struct_has(attributes, "joints")) {
            var _al = array_length(attributes.joints);
            for(var _i=0; _i< _al; _i++) {
                self.add_tree(string_repeat(" ", depth * TABSIZE) + "JOINTS_" + string(_i) + " : " + string(attributes.joints[_i]) + "\n");
            }
        }
        if(struct_has(attributes, "weights")) {
            var _al = array_length(attributes.weights);
            for(var _i=0; _i< _al; _i++) {
                self.add_tree(string_repeat(" ", depth * TABSIZE) + "WEIGHTS_" + string(_i) + " : " + string(attributes.weights[_i]) + "\n");
            }
        }
    }
    
    static process_primitive = function(primitive, depth = 0) {
        if(struct_has(primitive, "attributes")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "Attributes" + "\n");
            self.process_attributes(primitive.attributes, depth + 1);
        }
        if(struct_has(primitive, "indices")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "indices  : " + string(primitive.indices) + "\n");
        }
        if(struct_has(primitive, "material")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "material : " + string(primitive.material) + "\n");
        }
        if(struct_has(primitive, "mode")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "mode     : " + string(primitive.mode) + "\n");
        }
        if(struct_has(primitive, "targets")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "targets  : " + string(primitive.targets) + "\n");
        }
    }
    
    static process_mesh = function(mesh, depth = 0) {
        if(struct_has(mesh, "name")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "Mesh : " + mesh.name + "\n");
        }
        
        if(struct_has(mesh, "primitives")) {
            var _al = array_length(mesh.primitives);
            for(var _i = 0; _i < _al; _i++) {
                self.process_primitive(mesh.primitives[_i], depth + 1);
            }
        }
    }
        
    static process_node = function(node, depth = 0) {
        if(struct_has(node, "name")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "Node : " + node.name + "\n");
        }
        
        if(struct_has(node, "mesh")) {
            self.process_mesh(self.data.meshes[node.mesh], depth + 1);
        }
        
        
        if(struct_has(node, "children")) {
            var _al = array_length(node.children);
            for(var _i = 0; _i < _al; _i++) {
                var child = node.children[_i];
                self.process_node(self.data.nodes[child], depth + 1);
            }
        }
    }    
    
    static build = function() {
        self.tree = "";
        self.create_counts();
        
        if(is_int(self.data.scene)) {
            if(self.counts.scenes == 0) {
                return false;
            }
            if(self.counts.nodes == 0) {
                return false;
            } 

            if(self.data.scene < self.counts.scenes) {
                var _scene = self.data.scenes[self.data.scene];
                var _scene_nodes = array_length(_scene.nodes);
                for(var _n = 0; _n<_scene_nodes; _n++) {
                    var _node_index = _scene.nodes[_n];
                    if(_node_index < self.counts.nodes) {
                        var _node = self.data.nodes[_node_index];
                        self.process_node(_node);
                    }
                }
            }
        }
        
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

