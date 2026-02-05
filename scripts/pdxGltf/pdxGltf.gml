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
    self.json = undefined;
    self.load_time = 0;
    self.read_time = 0;
    self.process_time = 0;
    self.errval = false;
    self.data = undefined;

    self.accessorData = undefined;
    self.bufferData = undefined;
    self.imagesData = undefined;


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

    static free = function() {
    }
    
    static load_uri_buffer = function(uri) {
        var rval = -1;
        
        if(string_starts_with(uri, "data:")) {
            var temp = string_split(uri, ",", true, 1);
            if(array_length(temp) == 2) {
                rval = buffer_base64_decode(temp[1]);
            }
        } else {
            if(file_exists(self.filepath + uri)) {
                rval = buffer_create(0, buffer_grow, 1);
                if(buffer_exists(rval)) {
                    buffer_load_ext(rval, self.filepath + uri, 0);
                } else {
                    rval = -1;
                }
            } else {
                self.add_error("File not found : " + uri);
            }
        }
        
        return rval;
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
        
        if(struct_has(mesh, "weights")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "weights : " + string(mesh.weights) + "\n");
            self.add_warning("ToDo : Mesh weights not implemented yet");
        }
        
        
    }
        
    static process_node = function(node, depth = 0) {
        if(struct_has(node, "name")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "Node : " + node.name + "\n");
        }
        
        if(struct_has(node, "mesh")) {
            if(node.mesh < self.counts.meshes) {
                self.process_mesh(self.data.meshes[node.mesh], depth + 1);
            } else {
                self.add_error("Bad mesh index (" + string(node.mesh) + ")");
            }
        }
        
        if(struct_has(node, "children")) {
            var _al = array_length(node.children);
            for(var _i = 0; _i < _al; _i++) {
                var child = node.children[_i];
                if(child < self.counts.nodes) {
                    self.process_node(self.data.nodes[child], depth + 1);
                } else {
                    self.add_error("Bad node index (" + string(child) + ")");
                }
            }
        }
        
        if(struct_has(node, "camera")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "camera : " + string(node.camera) + "\n");
            self.add_warning("ToDo : Node camera not implemented yet");
        }
        
        if(struct_has(node, "skin")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "skin : " + string(node.skin) + "\n");
            self.add_warning("ToDo : Node skin not implemented yet");
        }
        
        if(struct_has(node, "matrix")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "matrix : " + string(node.matrix) + "\n");
            self.add_warning("ToDo : Node matrix not implemented yet");
        }
        
        if(struct_has(node, "rotation")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "rotation : " + string(node.rotation) + "\n");
            self.add_warning("ToDo : Node rotation not implemented yet : " +  + string(node.rotation));
        }
        
        if(struct_has(node, "scale")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "scale : " + string(node.scale) + "\n");
            self.add_warning("ToDo : Node scale not implemented yet");
        }
        
        if(struct_has(node, "translation")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "translation : " + string(node.translation) + "\n");
            self.add_warning("ToDo : Node translation not implemented yet");
        }
        
        if(struct_has(node, "weights")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "weights : " + string(node.weights) + "\n");
            self.add_warning("ToDo : Node weights not implemented yet");
        }
    }    
    
    static process_scene = function(scene, depth = 0) {
        if(struct_has(scene, "name")) {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "Scene : " + scene.name + "\n");
        } else {
            self.add_tree(string_repeat(" ", depth * TABSIZE) + "Scene : <no name>\n");
        }

        if(struct_has(scene, "nodes")) {
            var _al = array_length(scene.nodes);
            for(var _i = 0; _i < _al; _i++) {
                var _node = scene.nodes[_i];
                if(_node < self.counts.nodes) {
                    self.process_node(self.data.nodes[_node], depth + 1);
                } else {
                    self.add_error("Bad node index (" + string(_node) + ")");
                }
            }
        }
    }
    


    /*
    self.bufferView                      = undefined;    // integer                         The index of the bufferView.                            No
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0
    self.componentType                   = undefined;    // integer                         The datatype of the accessor’s components.              Yes
    self.normalized                      = undefined;    // boolean                         Integer values are normalized before usage.             No, default: false
    self.count                           = undefined;    // integer                         The number of elements referenced by this accessor.     Yes
    self.type                            = undefined;    // string                          Specifies the accessor’s type                           Yes
    self.max                             = undefined;    // number [1-16]                   Maximum value of each component in this accessor.       No
    self.min                             = undefined;    // number [1-16]                   Minimum value of each component in this accessor.       No
    self.sparse                          = undefined;    // accessor.sparse                 Sparse storage of elements that deviate.                No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    */
            
    static decodeAccessor = function() {
        
    }

    static createVariableType = function(type, count, componentType) {
        var value;
        switch(type) {
            case "SCALAR":
                value = new pdxGltfDataValueScalar(count, componentType);
                break;
            case "VEC2":
                value = new pdxGltfDataValueVector2(count, componentType);
                break;
            case "VEC3":
                value = new pdxGltfDataValueVector3(count, componentType);
                break;
            case "VEC4":
                value = new pdxGltfDataValueVector4(count, componentType);
                break;
            case "MAT2":
                value = new pdxGltfDataValueMatrix2(count, componentType);
                break;
            case "MAT3":
                value = new pdxGltfDataValueMatrix3(count, componentType);
                break;
            case "MAT4":
                value = new pdxGltfDataValueMatrix4(count, componentType);
                break;
            default:
                self.critical("Unknown accessor type");
                break;
        }                
        return value;
    }   
     
    static processAccessor = function(accessor, index) {
        var new_struct = self.createVariableType(accessor.type, accessor.count, accessor.componentType);
        if(struct_has(accessor, "bufferView")) {
            // If we have a bufferView read it in
            var view = self.data.bufferViews[accessor.bufferView];
            if(view.buffer < self.counts.bufferViews) {
                var buffer = self.bufferData[view.buffer];
                new_struct.read(buffer, view, accessor.byteOffset);
            } else {
                self.critical("Attempt to read out-of-bound bufferView");
            }

        } else {
            // With no bufferview initialise with zeros
            new_struct.init();
        }
  
        // Needs checking  
        if(struct_has(accessor, "sparse")) {
            new_struct.addSparse(accessor.sparse.count);

            new_struct.sparse.indices = self.createVariableType("SCALAR", accessor.sparse.count, accessor.sparse.indices.componentType);
            var sview1 = self.data.bufferViews[accessor.sparse.indices.bufferView];
            var buffer1 = self.bufferData[sview1.buffer];
            new_struct.sparse.indices.read(buffer1, sview1, accessor.byteOffset);

            new_struct.sparse.values = self.createVariableType(accessor.type, accessor.sparse.count, accessor.componentType);
            var sview2 = self.data.bufferViews[accessor.sparse.values.bufferView];
            var buffer2 = self.bufferData[sview2.buffer];
            new_struct.sparse.values.read(buffer2, sview2, accessor.byteOffset);
            
            // new_struct.applySparse();
            
        }
        
        self.accessorData[index] = new_struct;
    }

    
    static processAccessors = function(depth = 0) {
        var _al = array_length(self.data.accessors);
        if(is_undefined(self.accessorData)) {
            self.accessorData = array_create(_al, undefined);
        }
        for(var _i = 0; _i < _al; _i++) {
            self.processAccessor(self.data.accessors[_i], _i);
        }
    }
    
    static processImage = function(image, index) {
        var temp;
        if(struct_has(image, "uri")) {
            // If the image has a uri then we can read it from the file specified
            temp = self.load_uri_buffer(image.uri);
            if(buffer_exists(temp)) {
                self.imagesData[index] = temp;
            }
        } else {
            // Otherwise the image is in  BufferView
            show_debug_message("Buffered image");
            /*
            if(struct_exists(self, "binbuffer")) {
                if(!is_undefined(self.binbuffer)) {
                    // Re-assign the buffer reference
                    self.bufferdata[index] = self.binbuffer;
                    // This buffer has been transferred to buffers[_i] so remore the reference
                    // This will a;lso signify to the caller that the binary buffer from the 
                    // GLB has been re-assigned to a buffer
                    self.binbuffer = undefined;
                } else {
                    self.critical("GLB binary buffer already used")
                }
            }
             */
        }
    }
    

    static processImages = function(depth = 0) {
        var _al = array_length(self.data.images);
        if(is_undefined(self.imagesData)) {
            self.imagesData = array_create(_al, undefined);
        }
        for(var _i = 0; _i < _al; _i++) {
            self.processImage(self.data.images[_i], _i);
        }
    }
    /*
    static processBufferView = function(view) {
        
    }

    static processBufferViews = function(depth = 0) {
        var _al = array_length(self.data.bufferViews);
        for(var _i = 0; _i < _al; _i++) {
            self.processBufferView(self.data.bufferViews[_i]);
        }
    }
    */
    static processBuffer = function(buffer, index) {
        if(struct_has(buffer, "uri")) {
            // If the buffer has a uri then we can read it from the file specified
            var temp = self.load_uri_buffer(buffer.uri);
            if(buffer_exists(temp)) {
                self.bufferData[index] = temp;
            }
        } else {
            // Otherwise it SHOULD have been embedded in the glb so re-assign that one
            if(struct_exists(self, "binbuffer")) {
                if(!is_undefined(self.binbuffer)) {
                    // Re-assign the buffer reference
                    self.bufferData[index] = self.binbuffer;
                    // This buffer has been transferred to buffers[_i] so remore the reference
                    // This will a;lso signify to the caller that the binary buffer from the 
                    // GLB has been re-assigned to a buffer
                    self.binbuffer = undefined;
                } else {
                    self.critical("GLB binary buffer already used")
                }
            }
        }
    }
    
    static processBuffers = function(depth = 0) {
        var _al = array_length(self.data.buffers);
        if(is_undefined(self.bufferData)) {
            self.bufferData = array_create(_al, undefined);
        }
        for(var _i = 0; _i < _al; _i++) {
            self.processBuffer(self.data.buffers[_i], _i);
        }
        if(struct_exists(self, "binbuffer")) {
            // binbuffer only exists for GLB. Check that if it existed it has been consumed
            if(!is_undefined(self.binbuffer)) {
                self.add_error("GLB buffer not used");
            }
         }
    }
    
    static build = function() {
        self.process_time = get_timer();
        self.tree = "";
        
        // First create counts of all the main arrays
        self.create_counts();
        
        // Next we run some sanity checks        
        if(is_int(self.data.scene)) {
            if(self.counts.scenes == 0) {
                return false;
            }
            if(self.counts.nodes == 0) {
                return false;
            }
        }     
        
        // Fill the buffers from declared sources
        if(self.counts.buffers > 0) {
            self.processBuffers();
        }
        
        // Fill the buffers from declared sources
        if(self.counts.images > 0) {
            self.processImages();
        }
        
        // Now read/decode all bufferViews + buffers
        if(self.counts.accessors > 0) {
            self.processAccessors();
        }
         
        // Finally build scene(s)       
        if(self.data.scene < self.counts.scenes) {
            var _scene = self.data.scenes[self.data.scene];
            self.process_scene(_scene);
        }
        
        self.process_time = get_timer() - self.process_time;
        return true;
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
        }
        buffer_delete(_buffer);
        
        if(!is_undefined(self.json)) {
            self.data = new pdxGltfDataObject();
            self.data.init(self.json);
            self.load_time = get_timer() - self.load_time;
            
            return true;
        }
    }
    
    return false;
} 

function pdxGltf(): pdxGLTFBase() constructor {
    self.bufcount = 0;
    self.binbuffer = undefined;
    
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
                        var _outfile = self.filepath + self.filebase + ".json";
                        if(!file_exists(_outfile)) {
                            buffer_save_ext(_tempbuf1, _outfile, 0, _chunk_length);
                        }
                        
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        buffer_delete(_tempbuf1);
                        
                        break;
                    case gltfChunk.BIN:
                        if(!is_undefined(self.binbuffer)) {
                            self.critical("GLB has multiple buffer entries");
                        }
                        self.binbuffer = buffer_create(_chunk_length, buffer_fixed, 1);
                        buffer_copy(_buffer, buffer_tell(_buffer), _chunk_length, self.binbuffer, 0);
                        // Do stuff with tempobuf2
                        /*
                        if(self.filename == "world.glb") {
                            var _al = array_length(self.images);
                            array_resize(self.images, _al + 1)
                            self.images[_al] = new pdxImage();
                            self.images[_al].load_from_buffer(self.binbuffers[0], 69248, 1337486, "tex_world");
                        }
                        */
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
        
        if(!is_undefined(self.json)) {
            self.data = new pdxGltfDataObject();
            self.data.init(self.json);
            self.load_time = get_timer() - self.load_time;
            
            return true;
        }
        
        return false;

    }
    
}

