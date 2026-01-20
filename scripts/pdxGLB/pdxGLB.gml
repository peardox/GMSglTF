pdxGltfSpecificationVersion = "2.0.1";

enum glbChunk {
    JSON = 0x4E4F534A,
    BIN  = 0x004E4942
}

enum glbComponentType {
    s8      = 5120,   //    signed byte     Signed, 2’s comp     8
    u8      = 5121,   //    unsigned byte   Unsigned             8
    s16     = 5122,   //    signed short    Signed, 2’s comp    16
    u16     = 5123,   //    unsigned short  Unsigned            16
    u32     = 5125,   //    unsigned int    Unsigned            32
    float   = 5126    //    float           Signed              32
}

enum glbMeshPrimativeMode {
    POINTS,
    LINES,
    LINE_LOOP,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP,
    TRIANGLE_FAN
}

enum glbBufferViewTarget {
    ARRAY_BUFFER = 34962,
    ELEMENT_ARRAY_BUFFER = 34963
}

function pdxModelFile()  : ErrorStruct() constructor {
    filename = "";

    static open = function(afile) {
        if(file_exists(afile)) {
            self.filename = afile;
            return true;            
        }
        return false;
    }
}

function pdxGLTFparems() : ErrorStruct() constructor {
    static process_json = function(json_struct) {
        struct_foreach(json_struct, function(_name, _value) {
            self[$ _name] = _value;
        });
    }
}

function pdxGLTFasset(): pdxGLTFparems() constructor {
    self.version = "";

    static validate = function() {
        var rval = true;
        // Required glTF param, always validate
        if(global.pdxGltfSpecificationVersion <= self.version) {
            self.critical("Unsupported GlTF version (requested version specifies " + string(self.version) + " while we support " + string(global.pdxGltfSpecificationVersion) + ")");
        }
        // Optional glTF param, if present validate
        if(struct_exists(self, "minVerion")) {
            if(global.pdxGltfSpecificationVersion > self.minVersion) {
                self.add_error("Unsupported GlTF MINIMUM version (minVersion specifies " + string(self.minVersion) + " while we support " + string(global.pdxGltfSpecificationVersion) + ")");
                rval = false;
            }
        }
        
        return rval;
    }
}

function pdxGLTFscene(): pdxGLTFparems() constructor {
}

function pdxGLTFnode(): pdxGLTFparems() constructor {
}

function pdxGLTFmaterial(): pdxGLTFparems() constructor {
}

function pdxGLTFmesh_primative(): pdxGLTFparems() constructor {
    // The optional default is triangles, and is usually not in the json so it needs setting
    // This will be overwritten if present in json - typically by a non-triangle mode
    self.mode = glbMeshPrimativeMode.TRIANGLES;
    
    static process_json = function(json_struct) {
        struct_foreach(json_struct, function(_name, _value) {
            self[$ _name] = _value;
        });
        
        // attributes is a required value
        if(!struct_exists(self, "attributes")) {
            self.add_error("meshes.mesh.primative is REQUIRED");
        }
    }}


function pdxGLTFmesh(): pdxGLTFparems() constructor {
    self.primitaves = array_create(0);
    static process_json = function(json_struct) {
        struct_foreach(json_struct, function(_name, _value) {
            if(_name == "primitives") {
                if((typeof(_value) == "array")) {
                    var _al = array_length(_value);
                    array_resize(self.primitaves, _al);
                   
                    for(var _i = 0; _i < _al; _i++) {
                        if(typeof(_value[_i]) == "struct") {
                            self.primitaves[_i] = new pdxGLTFmesh_primative();
                            self.primitaves[_i].process_json(_value[_i]);
                        } else {
                            self.add_error("glTF mesh.primitive is not a struct - got " + typeof(json_array[_i]));
                        }
                    }
                                
                                
                    
                } else {
                    self.add_error("glTF mesh.primitives is not an array - got " + typeof(_value));
                }
            } else {
                self[$ _name] = _value;
            }
        });
    }
}


function pdxGLTFtexture(): pdxGLTFparems() constructor {
}

function pdxGLTFimage(): pdxGLTFparems() constructor {
}

function pdxGLTFaccessor(): pdxGLTFparems() constructor {
    self.byteOffset = 0;
    self.normalized = false;
    
    static process_json = function(json_struct) {
        struct_foreach(json_struct, function(_name, _value) {
            self[$ _name] = _value;
        });
        
        // componentType is a required value
        if(!struct_exists(self, "componentType")) {
            self.add_error("accessor.componentType is REQUIRED");
        }
        // count is a required value
        if(!struct_exists(self, "count")) {
            self.add_error("accessor.count is REQUIRED");
        }
        // type is a required value
        if(!struct_exists(self, "type")) {
            self.add_error("accessor.type is REQUIRED");
        }
    }
}

function pdxGLTFbufferView(): pdxGLTFparems() constructor {
    self.byteOffset = 0;
    
    static process_json = function(json_struct) {
        struct_foreach(json_struct, function(_name, _value) {
            self[$ _name] = _value;
        });
        
        // buffer is a required value
        if(!struct_exists(self, "buffer")) {
            self.add_error("bufferView.buffer is REQUIRED");
        }
        // byteLength is a required value
        if(!struct_exists(self, "byteLength")) {
            self.add_error("bufferView.byteLength is REQUIRED");
        }
    }
}

function pdxGLTFsampler(): pdxGLTFparems() constructor {
}

function pdxGLTFbuffer(): pdxGLTFparems() constructor {
    self.data = undefined;
}

function pdxGLTFanimation(): pdxGLTFparems() constructor {
}

function pdxGLTFskin(): pdxGLTFparems() constructor {
}

function pdxGLTFBase(): pdxModelFile() constructor {
    self.json = "";
    self.load_time = 0;
    self.read_time = 0;
    self.asset = new pdxGLTFasset();            // 5.17.5
    self.extensionsRequired = array_create(0);  // 5.17.2
    self.extensionsUsed = array_create(0);      // 5.17.1
    self.scene = NaN;                           // 5.17.14
    self.scenes = array_create(0);              // 5.17.15
    self.nodes = array_create(0);               // 5.17.12
    self.materials = array_create(0);           // 5.17.10
    self.meshes = array_create(0);              // 5.17.11
    self.textures = array_create(0);            // 5.17.17
    self.accessors = array_create(0);           // 5.17.3
    self.bufferViews = array_create(0);         // 5.17.7
    self.samplers = array_create(0);            // 5.17.13
    self.buffers = array_create(0);             // 5.17.6
    self.animations = array_create(0);          // 5.17.4
    self.skins = array_create(0);               // 5.17.16
    self.extras = {};                           // 5.17.19
    self.extensions = {};                       // 5.17.18
    self.cameras = array_create(0);             // 5.17.8
    self.images = array_create(0);              // 5.17.9

    static process_json_array = function(target, json_array) {
        var _al = array_length(json_array);
        array_resize(target, _al);
        for(var _i = 0; _i < _al; _i++) {
            target[_i] = json_array[_i];
        }
    }
    
    static process_json_scenes = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.scenes, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.scenes[_i] = new pdxGLTFscene();
                self.scenes[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF scene is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_nodes = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.nodes, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.nodes[_i] = new pdxGLTFnode();
                self.nodes[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF node is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_materials = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.materials, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.materials[_i] = new pdxGLTFmaterial();
                self.materials[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF material is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_meshes = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.meshes, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.meshes[_i] = new pdxGLTFmesh();
                self.meshes[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF mesh is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_textures = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.textures, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.textures[_i] = new pdxGLTFtexture();
                self.textures[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF texture is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_images = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.images, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.images[_i] = new pdxGLTFimage();
                self.images[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF iamge is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_accessors = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.accessors, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.accessors[_i] = new pdxGLTFaccessor();
                self.accessors[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF accessor is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_bufferViews = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.bufferViews, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.bufferViews[_i] = new pdxGLTFbufferView();
                self.bufferViews[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF bufferView is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_samplers = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.samplers, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.samplers[_i] = new pdxGLTFsampler();
                self.samplers[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF sampler is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_buffers = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.buffers, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.buffers[_i] = new pdxGLTFbuffer();
                self.buffers[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF buffer is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_animations = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.animations, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.animations[_i] = new pdxGLTFanimation();
                self.animations[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF animation is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json_skins = function(json_array) {
        var _al = array_length(json_array);
        array_resize(self.skins, _al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(json_array[_i]) == "struct") {
                self.skins[_i] = new pdxGLTFskin();
                self.skins[_i].process_json(json_array[_i]);
            } else {
                self.add_error("glTF skin is not a struct - got " + typeof(json_array[_i]));
            }
        }
    }
    
    static process_json = function(json_struct) {
        struct_foreach(json_struct, function(_name, _value) {
          show_debug_message("Type of " + string(_name) + " = " + typeof( _value) );
            if(_name == "asset") {
                if(typeof( _value) == "struct") {
                    self.asset.process_json(_value);
                } else {
                    self.add_error("glTF asset is not a struct - got " + typeof(_value));
                }
            } else if(_name == "extensionsRequired") {
                if(typeof( _value) == "array") {
                    self.process_json_array(self.extensionsRequired, _value);
                } else {
                    self.add_error("glTF extensionsRequired is not an array - got " + typeof(_value));
                }
            } else if(_name == "extensionsUsed") {
                if(typeof( _value) == "array") {
                    self.process_json_array(self.extensionsUsed, _value);
                } else {
                    self.add_error("glTF extensionsUsed is not an array - got " + typeof(_value));
                }
            } else if(_name == "scene") {
                if(typeof( _value) == "number") {
                    self.scene = _value;
                } else {
                    self.add_error("glTF scene is not a number - got " + typeof(_value));
                }
            } else if(_name == "scenes") {
                if(typeof( _value) == "array") {
                    process_json_scenes(_value);
                } else {
                    self.add_error("glTF scenes is not an array - got " + typeof(_value));
                }
            } else if(_name == "nodes") {
                if(typeof( _value) == "array") {
                    process_json_nodes(_value);
                } else {
                    self.add_error("glTF nodes is not an array - got " + typeof(_value));
                }
            } else if(_name == "materials") {
                if(typeof( _value) == "array") {
                    process_json_materials(_value);
                } else {
                    self.add_error("glTF materials is not an array - got " + typeof(_value));
                }
            } else if(_name == "meshes") {
                if(typeof( _value) == "array") {
                    process_json_meshes(_value);
                } else {
                    self.add_error("glTF meshes is not an array - got " + typeof(_value));
                }
            } else if(_name == "textures") {
                if(typeof( _value) == "array") {
                    process_json_textures(_value);
                } else {
                    self.add_error("glTF textures is not an array - got " + typeof(_value));
                }
            } else if(_name == "images") {
                if(typeof( _value) == "array") {
                    process_json_images(_value);
                } else {
                    self.add_error("glTF images is not an array - got " + typeof(_value));
                }
            } else if(_name == "accessors") {
                if(typeof( _value) == "array") {
                    process_json_accessors(_value);
                } else {
                    self.add_error("glTF accessors is not an array - got " + typeof(_value));
                }
            } else if(_name == "bufferViews") {
                if(typeof( _value) == "array") {
                    process_json_bufferViews(_value);
                } else {
                    self.add_error("glTF bufferViews is not an array - got " + typeof(_value));
                }
            } else if(_name == "samplers") {
                if(typeof( _value) == "array") {
                    process_json_samplers(_value);
                } else {
                    self.add_error("glTF samplers is not an array - got " + typeof(_value));
                }
            } else if(_name == "buffers") {
                if(typeof( _value) == "array") {
                    process_json_buffers(_value);
                } else {
                    self.add_error("glTF buffers is not an array - got " + typeof(_value));
                }
            } else if(_name == "animations") {
                if(typeof( _value) == "array") {
                    process_json_animations(_value);
                } else {
                    self.add_error("glTF animations is not an array - got " + typeof(_value));
                }
            } else if(_name == "skins") {
                if(typeof( _value) == "array") {
                    process_json_skins(_value);
                } else {
                    self.add_error("glTF skins is not an array - got " + typeof(_value));
                }
            } else if(_name == "extras") {
                if(typeof( _value) == "struct") {
                    process_json(_value);
                } else {
                    self.add_error("glTF extras is not an struct - got " + typeof(_value));
                }
            } else if(_name == "extensions") {
                if(typeof( _value) == "struct") {
                    process_json(_value);
                } else {
                    self.add_error("glTF extention is not an array - got " + typeof(_value));
                }
            } else {
                self.add_error("Unhandled glTF member " + string(_name));
            //    show_debug_message($"{_name}: {_value}");
            }
        });
    }
    
    static free = function() {
        /*
        var _il = array_length(self.images);
        for(var _i = 0; _i < _il; _i++) {
            self.images[_il].free();
        }
        */ 
        var _bl = array_length(self.buffers);
        for(var _i = 0; _i < _bl; _i++) {
            if(buffer_exists(self.buffers[_i].data)) {
                buffer_delete(self.buffers[_i].data);
                self.buffers[_i].data = undefined;
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
        buffer_load_ext(_buffer, self.filename, 0);
        var _bsize = buffer_get_size(_buffer);
        self.read_time = get_timer() - self.load_time;
        if(_bsize > 0) {
            var _json_txt = buffer_read(_buffer, buffer_string);
            self.json = json_parse(_json_txt);
            self.process_json(self.json);                    
            show_debug_message(_json_txt);
        }
        buffer_delete(_buffer);
    }
} 

function pdxGLB(): pdxGLTFBase() constructor {
    static read = function() {
        self.load_time = get_timer();
        var _buffer = buffer_create(0, buffer_grow, 1);
        if(_buffer == -1) {
            throw("Can't create buffer");
        }
        buffer_load_ext(_buffer, self.filename, 0);
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
                    case glbChunk.JSON:
                        var _tempbuf1 = buffer_create(_chunk_length, buffer_fixed, 1);
                        buffer_copy(_buffer, buffer_tell(_buffer), _chunk_length, _tempbuf1, 0);
                        var _json_txt = buffer_read(_tempbuf1, buffer_string);
                        self.json = json_parse(_json_txt);
                        self.process_json(self.json);                    
                        show_debug_message(_json_txt);
                        buffer_seek(_buffer, buffer_seek_relative, _chunk_length);
                        buffer_delete(_tempbuf1);
                        
                        break;
                    case glbChunk.BIN:
                        if(array_length(self.buffers) <> 1) {
                            self.critical("GLB has multiple buffer entries");
                        }
                        self.buffers[0].data = buffer_create(_chunk_length, buffer_fixed, 1);
                        buffer_copy(_buffer, buffer_tell(_buffer), _chunk_length, self.buffers[0].data, 0);
                        // Do stuff with tempobuf2
                        if(self.filename == working_directory + "/glb/world.glb") {
                            var _al = array_length(self.images);
                            array_resize(self.images, _al + 1)
                            self.images[_al] = new pdxImage();
                            self.images[_al].load_from_buffer(self.buffers[0].data, 69248, 1337486, "tex_world");
                            /*
                            var _img_buf = buffer_create(1337486, buffer_fixed, 1);
                            buffer_copy(_tempbuf2, 69248, 1337486, _img_buf, 0);
                            var _sprite_data = {
                                sprites : 
                                {        
                                    world : 
                                    {
                                        width : 1024,
                                        height : 1024,
                                        frames :
                                        [ 
                                            { x : 0, y : 0 }
                                        ],
                                    }}};
                            texturegroup_add("tex_world", _img_buf, _sprite_data);
                            texturegroup_load("tex_world");
                            self.add_error("texture = " + string(texturegroup_get_status("tex_world")));
                            // buffer_delete(_img_buf);
                            */
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
        self.asset.validate();
                
        self.load_time = get_timer() - self.load_time;
        
        return true;
    }
    
}

