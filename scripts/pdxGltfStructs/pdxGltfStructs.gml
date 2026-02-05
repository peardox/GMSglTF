#macro USE_DEFAULTS false

enum gltfVariableType {
    integer,
    float,
    vec3,
    vec4,
    object,
    array
}

enum gltfChunk {
    JSON = 0x4E4F534A,
    BIN  = 0x004E4942
}

enum gltfAccessorType {
    UNKNOWN = -1,
    SCALAR,
    VEC2,
    VEC3,
    VEC4,
    MAT2,
    MAT3,
    MAT4
}

enum gltfComponentType {
    UNKNOWN = -1,
    BYTE               = 5120,   //    signed byte     Signed, 2’s comp     8
    UNSIGNED_BYTE      = 5121,   //    unsigned byte   Unsigned             8
    SHORT              = 5122,   //    signed short    Signed, 2’s comp    16
    UNSIGNED_SHORT     = 5123,   //    unsigned short  Unsigned            16
    UNSIGNED_INT       = 5125,   //    unsigned int    Unsigned            32
    FLOAT              = 5126    //    float           Signed              32
}

enum gltfMeshPrimitiveMode {
    POINTS,
    LINES,
    LINE_LOOP,
    LINE_STRIP,
    TRIANGLES,
    TRIANGLE_STRIP,
    TRIANGLE_FAN
}

enum gltfBufferViewTarget {
    ARRAY_BUFFER = 34962,
    ELEMENT_ARRAY_BUFFER = 34963
}

function ComponentTypeToString(value) {
    switch(value) {
        case gltfComponentType.BYTE:
            return "S08";
        case gltfComponentType.FLOAT:
            return "F32";
        case gltfComponentType.SHORT:
            return "S16";
        case gltfComponentType.UNSIGNED_BYTE:
            return "U08";
        case gltfComponentType.UNSIGNED_INT:
            return "U32";
        case gltfComponentType.UNSIGNED_SHORT:
            return "U16";
    }    
    
    return false;
    
}

function AccessorTypeToString(value) {
    switch(value) {
        case gltfAccessorType.SCALAR:
            return "SCLR";
        case gltfAccessorType.VEC2:
            return "VEC2";
        case gltfAccessorType.VEC3:
            return "VEC3";
        case gltfAccessorType.VEC4:
            return "VEC4";
        case gltfAccessorType.MAT2:
            return "MAT2";
        case gltfAccessorType.MAT3:
            return "MAT3";
        case gltfAccessorType.MAT4:
            return "MAT4";
    }
    return "????";
}


function pdxGltfDataAbstractBase() : pdxException() constructor {
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No

    static copy_extensions = function(object) {
        if(typeof(object) == "struct") {
            self.extensions = object;
            return true;
        }
        return false;
    }
    
    static copy_extras = function(value) {
        self.extras = value;
    }
    
    static copy_unhandled = function(name, value) {
        self[$ name] = value;
        self.add_warning("Unhandled " + typeof(value) + " value with key = " + string(name));
    }
    
    static copy_object = function(object) {
        if(typeof(object) == "struct") {
         struct_foreach(object, function(_name, _value) {
             self[$ _name] = _value;
             });
            return true;
        } else {
            return false;
        }
    }    
        
    static copy_array = function(target, array, type) {
        var _res = true;
        var _al = array_length(array);
        self[$ target] = array_create(_al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(array[_i]) == type) {
                self[$ target][_i] = array[_i];
            } else {
                self[$ target] = undefined;
                _res = false;
                self.add_error("Array " + target + " index " + string(_i) + " value is not " + type);
                break;
            }
        }
        return _res;
    }
    
    static copy_integer = function(target, value) {
        var _res = true;
        if(typeof(value) == "number" && is_int(value)) {
            self[$ target] = value;
        } else {
            self[$ target] = undefined;
            _res = false;
            self.add_error("Value " + target + " is not an integer");
        }
        return _res;
    }
    
    static copy_float = function(target, value) {
        var _res = true;
        if(typeof(value) == "number") {
            self[$ target] = value;
        } else {
            self[$ target] = undefined;
            _res = false;
            self.add_error("Value " + target + " is not a float");
        }
        return _res;
    }
    
    static copy_multi_float = function(target, value, len) {
        var _res = true;
        if(typeof(value) != "array") {
            return false;
        }
        if(array_length(value) != len) {
            return false;
        }
        
        self[$ target] = array_create(len);
        
        for(var _i=0; _i < len; _i++) {
            if(typeof(value[_i]) == "number") {
                self[$ target][_i] = value[_i];
            } else {
                self[$ target] = undefined;
                _res = false;
                self.add_error("Value " + target + " index " + string(_i) + " is not a float");
                break;
            }
        }
        return _res;
    }
    
    static copy_string = function(target, value) {
        var _res = true;
        if(typeof(value) == "string") {
            self[$ target] = value;
        } else {
            self[$ target] = undefined;
            _res = false;
            self.add_error("Value " + target + " is not a string");
        }
        return _res;
    }
    
    static copy_integer_array = function(target, array) {
        var _res = true;
        var _al = array_length(array);
        self[$ target] = array_create(_al);
        for(var _i = 0; _i < _al; _i++) {
            if(typeof(array[_i]) == "number" && is_int(array[_i])) {
                self[$ target][_i] = array[_i];
            } else {
                self[$ target] = undefined;
                _res = false;
                self.add_error("Array " + target + " index " + string(_i) + " value is not an integer");
                break;
            }
        }
        return _res;
    }
    
    static do_validate = function(required, defaults) {
        if(is_array(required)) {
            var _al = array_length(required);
            for(var _i=0; _i<_al; _i++) {
                if(is_string(required[_i][0])) {
                    if(struct_exists(self, required[_i][0])) {
                        if(is_undefined(self[$ required[_i][0]])) {
                            self.add_error("Required value for " + required[_i][0] + " is undefined");
                        }
                    } else {
                        self.add_error("Required value for " + required[_i][0] + " is missing");
                    }
                }
                
            }
        }

        if(is_array(defaults)) {
            var _al = array_length(defaults);
            for(var _i=0; _i<_al; _i++) {
                if((array_length(defaults[_i]) == 2) && is_string(defaults[_i][0])) {
                    if(struct_exists(self, defaults[_i][0])) {
                        if(is_undefined(self[$ defaults[_i][0]])) {
                            self[$ defaults[_i][0]] = defaults[_i][1];
                        }
                    }
                }
                
            }
        }
        
        if(self.has_errors()) {
            show_debug_message(self.error);
        }
    }
}

function pdxGltfDataObject() : pdxGltfDataAbstractBase() constructor {
    self.extensionsUsed                  = undefined;    // string [1-*]                    Names of glTF extensions used in this asset.            No
    self.extensionsRequired              = undefined;    // string [1-*]                    Names of glTF extensions required to properly load      No
    self.accessors                       = undefined;    // accessor [1-*]                  An array of accessors.                                  No
    self.animations                      = undefined;    // animation [1-*]                 An array of keyframe animations.                        No
    self.asset                           = undefined;    // asset                           Metadata about the glTF asset.                          Yes
    self.buffers                         = undefined;    // buffer [1-*]                    An array of buffers.                                    No
    self.bufferViews                     = undefined;    // bufferView [1-*]                An array of bufferViews.                                No
    self.cameras                         = undefined;    // camera [1-*]                    An array of cameras.                                    No
    self.images                          = undefined;    // image [1-*]                     An array of images.                                     No
    self.materials                       = undefined;    // material [1-*]                  An array of materials.                                  No
    self.meshes                          = undefined;    // mesh [1-*]                      An array of meshes.                                     No
    self.nodes                           = undefined;    // node [1-*]                      An array of nodes.                                      No
    self.samplers                        = undefined;    // sampler [1-*]                   An array of samplers.                                   No
    self.scene                           = undefined;    // integer                         The index of the default scene.                         No
    self.scenes                          = undefined;    // scene [1-*]                     An array of scenes.                                     No
    self.skins                           = undefined;    // skin [1-*]                      An array of skins.                                      No
    self.textures                        = undefined;    // texture [1-*]                   An array of textures.                                   No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
    
    static init = function(object) {
        struct_foreach(object, function(_name, _value) {
            // show_debug_message("Type of " + string(_name) + " = " + typeof( _value) );
            var _val_type = typeof(_value);
            if(_name == "extras") {
                self.copy_extras(_value);
            } else {
                switch(_val_type) {
                    case "array":
                        var _al = array_length(_value);
                        switch(_name) {
                            case  "extensionsRequired":
                                if(!self.copy_array("extensionsRequired", _value, "string")) {
                                    self.add_error("Bad Array for extensionsRequired");
                                }
                                break;
                            case "extensionsUsed":
                                if(!self.copy_array("extensionsUsed", _value, "string")) {
                                    self.add_error("Bad Array for extensionsUsed");
                                }
                                break;
                            case "scenes":
                                self.scenes = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.scenes[_i] = new pdxGltfDataScene();
                                    self.scenes[_i].init(_value[_i]);
                                }
                                break;
                            case "nodes":
                                self.nodes = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.nodes[_i] = new pdxGltfDataNode();
                                    self.nodes[_i].init(_value[_i]);
                                }
                                break;
                            case "materials":
                                self.materials = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.materials[_i] = new pdxGltfDataMaterial();
                                    self.materials[_i].init(_value[_i]);
                                }
                                break;
                            case "meshes":
                                self.meshes = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.meshes[_i] = new pdxGltfDataMesh();
                                    self.meshes[_i].init(_value[_i]);
                                }
                                break;
                            case "textures":
                                self.textures = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.textures[_i] = new pdxGltfDataTexture();
                                    self.textures[_i].init(_value[_i]);
                                }
                                break;
                            case "images":
                                self.images = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.images[_i] = new pdxGltfDataImage();
                                    self.images[_i].init(_value[_i]);
                                }
                                break;
                            case "accessors":
                                self.accessors = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.accessors[_i] = new pdxGltfDataAccessor();
                                    self.accessors[_i].init(_value[_i]);
                                }
                                break;
                            case "bufferViews":
                                self.bufferViews = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.bufferViews[_i] = new pdxGltfDataBufferView();
                                    self.bufferViews[_i].init(_value[_i]);
                                }
                                break;
                            case "buffers":
                                self.buffers = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.buffers[_i] = new pdxGltfDataBuffer();
                                    self.buffers[_i].init(_value[_i]);
                                }
                                break;
                            case "samplers":
                                self.samplers = array_create(_al);
                                for(var _i=0; _i< _al; _i++) {
                                    self.samplers[_i] = new pdxGltfDataSampler();
                                    self.samplers[_i].init(_value[_i]);
                                }
                                break;
                            default:
                                self.copy_unhandled(_name, _value);
                                break;
                        }
                        break;
                    case "struct":
                        switch(_name) {
                            case "asset":
                                self.asset = new pdxGltfDataAsset();
                                self.asset.init(_value);
                                break;
                            case "extensions":
                                if(!self.copy_extensions(_value)) {
                                    self.add_error("glTF extensions expected struct - got " + typeof(_value));
                                }
                                break;
                            default:
                                self.copy_unhandled(_name, _value);
                                break;
                        }
                        break;
                    case "number":
                        switch(_name) {
                            case "scene":
                                self.scene = _value;
                                break;
                            default:
                                self.copy_unhandled(_name, _value);
                                break;
                        }
                        break;
                    default:
                        if(_name == "extras") {
                            self.copy_extensions(_value);
                        } else {
                            self.copy_unhandled(_name, _value);
                        }
                        break;
                }
            }
        }
        
        
        );    
        
        if(is_undefined(self.asset)) {
            self.critical("Model is missing required asset element");
        }
    }
}

function pdxGltfDataAsset() : pdxGltfDataAbstractBase() constructor {
    self.copyright                       = undefined;    // string                          copyright for display to credit the content creator     No
    self.generator                       = undefined;    // string                          Tool that generated this glTF model                     No
    self.version                         = undefined;    // string                          The glTF version in the form of <major>.<minor>         Yes
    self.minVersion                      = undefined;    // string                          The minimum glTF version in the form of <major>.<minor> No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of scene is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "version") {
                if(!self.copy_string("version", _value)) {
                    self.add_error("asset element version is not a string");
                }
            } else if(_name == "copyright") {
                if(!self.copy_string("copyright", _value)) {
                    self.add_error("asset element copyright is not a string");
                }
            } else if(_name == "generator") {
                if(!self.copy_string("generator", _value)) {
                    self.add_error("asset element generator is not a string");
                }
            } else if(_name == "minVersion") {
                if(!self.copy_string("minVersion", _value)) {
                    self.add_error("asset element minVersion is not a string");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_undefined(self.version)) {
            self.critical("GLTF is missing REQUIRED version value in asset section");
        }
    }
}

function pdxGltfDataScene() : pdxGltfDataAbstractBase() constructor {
    self.nodes                           = undefined;    // integer [1-*]                   The indices of each root node.                          No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of scene is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("Scene name is not a string");
                }
            } else if(_name == "nodes") {
                if(typeof(_value) == "array") {
                    if(!self.copy_integer_array("nodes", _value)) {
                        self.add_error("Bad Array for nodes");
                    }
                } else {
                    self.add_error("Node nodes is not an array");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });

    }
}

function pdxGltfDataNode() : pdxGltfDataAbstractBase() constructor {
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.children                        = undefined;    // integer [1-*]                   The indices of this node’s children.                    No, default: [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]
    self.mesh                            = undefined;    // integer                         The index of the mesh in this node.                     No
    self.camera                          = undefined;    // integer                         The index of the camera referenced by this node.        No
    self.skin                            = undefined;    // integer                         The index of the skin referenced by this node.          No
    self.matrix                          = undefined;    // number [16]                     A floating-point 4x4 transformation matrix              No
    self.rotation                        = undefined;    // number [4]                      The node’s unit quaternion rotation (x, y, z, w)        No, default: [0,0,0,1]
    self.scale                           = undefined;    // number [3]                      The node’s non-uniform scale along x, y, and z          No, default: [1,1,1]
    self.translation                     = undefined;    // number [3]                      The node’s translation along the x, y, and z axes.      No, default: [0,0,0]
    self.weights                         = undefined;    // number [1-*]                    The weights of the instantiated morph target.           No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(typeof(_value) == "string") {
                    self.name = _value;
                } else {
                    self.add_error("Node name is not a string");
                }
            } else if(_name == "children") {
                if(typeof(_value) == "array") {
                    if(!self.copy_integer_array("children", _value)) {
                        self.add_error("Bad Array for children");
                    }
                } else {
                    self.add_error("Node children is not an array");
                }
            } else if(_name == "skin") { 
                if(!self.copy_integer("skin", _value)) {
                    self.add_error("node element skin is not an integer");
                }
            } else if(_name == "camera") { 
                if(!self.copy_integer("camera", _value)) {
                    self.add_error("node element camera is not an integer");
                }
            } else if(_name == "mesh") { 
                if(!self.copy_integer("mesh", _value)) {
                    self.add_error("node element mesh is not an integer");
                }
            
            } else if(_name == "scale") { 
                if(!self.copy_multi_float("scale", _value, 3)) {
                    self.add_error("Bad Array for node element scale");
                }
            } else if(_name == "translation") { 
                if(!self.copy_multi_float("translation", _value, 3)) {
                    self.add_error("Bad Array for node element translation");
                }
            } else if(_name == "rotation") { 
                if(!self.copy_multi_float("rotation", _value, 4)) {
                    self.add_error("Bad Array for node element rotation");
                }
            } else if(_name == "weights") { 
                if(!self.copy_array("weights", _value, "number")) {
                    self.add_error("Bad Array for node element weights");
                }
            } else if(_name == "matrix") { 
                if(!self.copy_multi_float("matrix", _value, 16)) {
                    self.add_error("Bad Array for node element matrix");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
            
            
        });
		
        if(USE_DEFAULTS) {
	        if(is_undefined(self.matrix)) {
	            self.matrix = [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];
	        }
	        if(is_undefined(self.rotation)) {
	            self.rotation = [0,0,0,1];
	        }
	        if(is_undefined(self.scale)) {
	            self.scale = [1,1,1];
	        }
	        if(is_undefined(self.translation)) {
	            self.translation = [0,0,0];
	        }
		}
        
    }
}
 
function pdxGltfDataMesh() : pdxGltfDataAbstractBase() constructor {
    self.primitives                      = undefined;    // mesh.primitive [1-*]            An array of primitives, each defining geometry.         Yes
    self.weights                         = undefined;    // number [1-*]                    Array of weights to be applied to the morph targets.    No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("Mesh name is not a string");
                }
            } else if(_name == "primitives") {
                if(typeof(_value) == "array") {
                    var _al = array_length(_value);
                    self.primitives = array_create(_al);
                    for(var _i = 0; _i<_al; _i++) {
                        self.primitives[_i] = new pdxGltfDataMeshPrimitive();
                        self.primitives[_i].init(_value[_i]);
                    }
                } else {
                    self.add_error("Mesh primitives is not an array");
                }
            } else if(_name == "weights") { 
                if(typeof(_value) == "array") {
                    var _al = array_length(_value);
                } else {
                    self.add_error("Mesh weights is not an array");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });

        // self.attributes is REQUIRED
        if(is_undefined(self.primitives)) {
            self.critical("Mesh has no primitives");
        }                
    }
}

function pdxGltfDataMeshPrimitive() : pdxGltfDataAbstractBase() constructor {
    self.attributes                      = undefined;    // object                          A plain JSON object,                                    Yes
    self.indices                         = undefined;    // integer                         The index of the accessor containing vertex indices.    No
    self.material                        = undefined;    // integer                         The index of the material to apply.                     No
    self.mode                            = undefined;    // integer                         The topology type of primitives to render.              No, default: 4
    self.targets                         = undefined;    // object [1-*]                    An array of morph targets.                              No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "attributes") {
                if(typeof(_value) == "struct") {
                    self.attributes = new pdxGltfDataMeshAttributes();
                    self.attributes.init(_value);
                } else {
                    self.add_error("primitive element attributes is not a struct");
                }
            } else if(_name == "indices") {
                if(!self.copy_integer("indices", _value)) {
                    self.add_error("primitive element indices is not an integer");
                }
            } else if(_name == "material") {
                if(!self.copy_integer("material", _value)) {
                    self.add_error("primitive element material is not an integer");
                }
            } else if(_name == "mode") {
                if(!self.copy_integer("mode", _value)) {
                    self.add_error("primitive element mode is not an integer");
                }
            } else if(_name == "targets") {
                if(typeof(_value) == "array") {
                    var _al = array_length(_value);
                    self.targets = array_create(_al);
                    for(var _i = 0; _i<_al; _i++) {
                        self.tagets[_i] = _value[_i];
                    }
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        // self.mode is optional with a default value of 4
        if(is_undefined(self.mode)) {
            self.mode = 4;
        }
        // self.attributes is REQUIRED
        if(is_undefined(self.attributes)) {
            self.critical("Mesh has no attributes");
        }
    }
}

function pdxGltfDataMeshAttributes() : pdxGltfDataAbstractBase() constructor {
    self.POSITION                        = undefined;
    self.NORMAL                          = undefined;
    self.TANGENT                         = undefined;
    self.texcoord                        = undefined;
    self.color                           = undefined;
    self.joints                          = undefined;
    self.weights                         = undefined;
    
    // Some primitive entries are of the form <NAME>_<INDEX>
    // This will split out the index and convert into array format
    static set_underscore_array_value = function(target, name, value) {
        var index = -1;

        var underscore_parts = string_split(string_trim(name), "_", true);
        if(array_length(underscore_parts) == 2) {
            if(is_string_numeric(underscore_parts[1])) {
                index = int64(underscore_parts[1]);
            }
        } else {
            return false;    
        }
        if(index < 0) {
            return false;    
        }
        // The order of creation may not be sequntial so when
        // defining array set any lower indicies to undefined
        // as this will allow trapping bad values easier
        if(is_undefined(self[$ target])) {
            self[$ target] = array_create((index + 1), undefined);
        }
        // Note that it is _possible_ that this may create
        // an array value of zero (bad + possibly wrong)
        // Workaround would be cumbersome and highly unlikely
        if(array_length(self[$ target]) < (index + 1)) {
            array_resize(self[$ target], index + 1);
        }
        
        if(is_int(value)) {
            self[$ target][index] = value;
            return true;
        }
        
        return false;        
    }
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "POSITION") {
                if(!self.copy_integer("POSITION", _value)) {
                    self.add_error("attribute element POSITION is not an integer");
                }
            } else if(_name == "NORMAL") {
                if(!self.copy_integer("NORMAL", _value)) {
                    self.add_error("attribute element NORMAL is not an integer");
                }
            } else if(_name == "TANGENT") {
                if(!self.copy_integer("TANGENT", _value)) {
                    self.add_error("attribute element TANGENT is not an integer");
                }
            } else if(_name == "COLOR_") {
                if(!self.set_underscore_array_value("color",_name, _value)) {
                    self.add_error("attribute element " + _name + " is not an integer");
                }
            } else if(string_starts_with(_name, "TEXCOORD_")) { 
                if(!self.set_underscore_array_value("texcoord",_name, _value)) {
                    self.add_error("attribute element " + _name + " is not an integer");
                }
            } else if(string_starts_with(_name, "JOINTS_")) {
                if(!self.set_underscore_array_value("joints",_name, _value)) {
                    self.add_error("attribute element " + _name + " is not an integer");
                }
            } else if(string_starts_with(_name, "WEIGHTS_")) {
                if(!self.set_underscore_array_value("weights",_name, _value)) {
                    self.add_error("attribute element " + _name + " is not an integer");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_array(self.texcoord)) {
            var _al = array_length(self.texcoord);
            for(var _i=0; _i<_al;_i++) {
                if(is_undefined(self.texcoord[_i])) {
                    self.critical("TEXCOORDs are not sequential")
                }
                if(self.texcoord[_i] == 0) {
                    self.add_warning("Suspicious TEXCOORDs value of zero")
                }
            }
        }
        if(is_array(self.joints)) {
            var _al = array_length(self.joints);
            for(var _i=0; _i<_al;_i++) {
                if(is_undefined(self.joints[_i])) {
                    self.critical("JOINTs are not sequential")
                }
                if(self.joints[_i] == 0) {
                    self.add_warning("Suspicious JOINTs value of zero")
                }
            }
        }
        if(is_array(self.weights)) {
            var _al = array_length(self.weights);
            for(var _i=0; _i<_al;_i++) {
                if(is_undefined(self.weights[_i])) {
                    self.critical("WEIGHTs are not sequential")
                }
                if(self.weights[_i] == 0) {
                    self.add_warning("Suspicious WEIGHTs value of zero")
                }
            }
        }
    
    }
}

function pdxGltfDataMaterial() : pdxGltfDataAbstractBase() constructor {
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.pbrMetallicRoughness            = undefined;    // material.pbrMetallicRoughness   PBR metallic-roughness material model                   No
    self.normalTexture                   = undefined;    // material.normalTextureInfo      The tangent space normal texture.                       No                          
    self.occlusionTexture                = undefined;    // material.occlusionTextureInfo   The occlusion texture.                                  No                          
    self.emissiveTexture                 = undefined;    // textureInfo                     The emissive texture.                                   No                         
    self.emissiveFactor                  = undefined;    // number [3]                      The factors for the emissive color of the material.     No, default: [0,0,0]       
    self.alphaMode                       = undefined;    // string                          The alpha rendering mode of the material.               No, default: "OPAQUE"
    self.alphaCutoff                     = undefined;    // number                          The alpha cutoff value of the material.                 No, default: 0.5
    self.doubleSided                     = undefined;    // boolean                         Specifies whether the material is double sided.         No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("material element name is not a string");
                }
            } else if(_name == "pbrMetallicRoughness") {
                if(typeof(_value)=="struct") {
                    self.pbrMetallicRoughnes = new pdxGltfDataMaterialPbrMetallicRoughness();
                    self.pbrMetallicRoughnes.init(_value);
                } else {
                    self.add_error("material element pbrMetallicRoughness is not a struct");
                }
            } else if(_name == "normalTexture") {
                if(typeof(_value)=="struct") {
                    self.normalTexture = new pdxGltfDataMaterialNormalTextureInfo();
                    self.normalTexture.init(_value);
                } else {
                    self.add_error("material element normalTexture is not a struct");
                }
            } else if(_name == "occlusionTexture") {
                if(typeof(_value)=="struct") {
                    self.occlusionTexture = new pdxGltfDataMaterialOcclusionTextureInfo();
                    self.occlusionTexture.init(_value);
                } else {
                    self.add_error("material element occlusionTexture is not a struct");
                }
            } else if(_name == "emissiveTexture") {
                if(typeof(_value)=="struct") {
                    self.emissiveTexture = new pdxGltfDataTextureInfo();
                    self.emissiveTexture.init(_value);
                } else {
                    self.add_error("material element emissiveTexture is not a struct");
                }
            } else if(_name == "emissiveFactor") {
                if(!self.copy_multi_float("emissiveFactor", _value, 3)) {
                    self.add_error("material element emissiveFactor is not a float(3)");
                }
            } else if(_name == "alphaMode") {
                if(!self.copy_string("alphaMode", _value)) {
                    self.add_error("material element alphaMode is not a string");
                }
            } else if(_name == "alphaCutoff") {
                if(!self.copy_float("alphaCutoff", _value)) {
                    self.add_error("material element alphaCutoff is not a float");
                }
            } else if(_name == "doubleSided") {
                if(typeof(_value) == "bool") {
                    self.doubleSided = _value;
                } else {
                    self.add_error("material element doubleSided is not a bool");
                }            
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_undefined(self.alphaMode)) {
            self.alphaMode = "OPAQUE";
        }
        if(is_undefined(self.alphaCutoff)) {
            self.alphaCutoff = 0.5;
        }
        if(is_undefined(self.emissiveFactor)) {
            self.emissiveFactor = [0, 0, 0];
        }    
    }
    

}

function pdxGltfDataMaterialPbrMetallicRoughness() : pdxGltfDataAbstractBase() constructor {
    self.baseColorFactor                 = undefined;    // number [4]                      The factors for the base color of the material.         No, default: [1,1,1,1]
    self.baseColorTexture                = undefined;    // textureInfo                     The base color texture.                                 No
    self.metallicFactor                  = undefined;    // number                          The factor for the metalness of the material.           No, default: 1
    self.roughnessFactor                 = undefined;    // number                          The factor for the roughness of the material.           No, default: 1
    self.metallicRoughnessTexture        = undefined;    // textureInfo                     The metallic-roughness texture.                         No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "baseColorFactor") {
                if(!self.copy_multi_float("baseColorFactor", _value, 4)) {
                    self.add_error("material element baseColorFactor is not a float(4)");
                }
            } else if(_name == "metallicFactor") {
                if(!self.copy_float("metallicFactor", _value)) {
                    self.add_error("material element metallicFactor is not a float");
                }
            } else if(_name == "roughnessFactor") {
                if(!self.copy_float("roughnessFactor", _value)) {
                    self.add_error("material element roughnessFactor is not a float");
                }
            } else if(_name == "baseColorTexture") {
                if(typeof(_value)=="struct") {
                    self.baseColorTexture = new pdxGltfDataTextureInfo();
                    self.baseColorTexture.init(_value);
                } else {
                    self.add_error("material element baseColorTexture is not a struct");
                }
            } else if(_name == "metallicRoughnessTexture") {
                if(typeof(_value)=="struct") {
                    self.metallicRoughnessTexture = new pdxGltfDataTextureInfo();
                    self.metallicRoughnessTexture.init(_value);
                } else {
                    self.add_error("material element metallicRoughnessTexture is not a struct");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_undefined(self.metallicFactor)) {
            self.metallicFactor = 1;
        }
        if(is_undefined(self.roughnessFactor)) {
            self.roughnessFactor = 1;
        }
        if(is_undefined(self.baseColorFactor)) {
            self.baseColorFactor = [1, 1, 1, 1];
        }    
    }
    
}

function pdxGltfDataMaterialNormalTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD attribute           No, default: 0
    self.scale                           = undefined;    // number                          The scalar parameter applied to each normalTex vector   No, default: 1
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of TewxtureInfo is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "index") {
                if(!self.copy_integer("index", _value)) {
                    self.add_error("material element index is not an integer");
                }
            } else if(_name == "texCoord") {
                if(!self.copy_integer("texCoord", _value)) {
                    self.add_error("material element texCoord is not an integer");
                }
            } else if(_name == "scale") {
                if(!self.copy_float("scale", _value)) {
                    self.add_error("material element scale is not a float");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_undefined(self.texCoord)) {
            self.texCoord = 0;
        }
        if(is_undefined(self.scale)) {
            self.scale = 1;
        }
        if(is_undefined(self.index)) {
            self.critical("TextureInfo index not set");
        }
    
    }
    
}

function pdxGltfDataMaterialOcclusionTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
    self.strength                        = undefined;    // number                          A scalar multiplier for the amount of occlusion.        No, default: 1
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of TewxtureInfo is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "index") {
                if(!self.copy_integer("index", _value)) {
                    self.add_error("material element index is not an integer");
                }
            } else if(_name == "texCoord") {
                if(!self.copy_integer("texCoord", _value)) {
                    self.add_error("material element texCoord is not an integer");
                }
            } else if(_name == "strength") {
                if(!self.copy_float("strength", _value)) {
                    self.add_error("material element strength is not a float");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_undefined(self.texCoord)) {
            self.texCoord = 0;
        }
        if(is_undefined(self.strength)) {
            self.strength = 1;
        }
        if(is_undefined(self.index)) {
            self.critical("TextureInfo index not set");
        }
    
    }
    
}

function pdxGltfDataTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of TewxtureInfo is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "index") {
                if(!self.copy_integer("index", _value)) {
                    self.add_error("material element index is not an integer");
                }
            } else if(_name == "texCoord") {
                if(!self.copy_integer("texCoord", _value)) {
                    self.add_error("material element texCoord is not an integer");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_undefined(self.texCoord)) {
            self.texCoord = 0;
        }
        if(is_undefined(self.index)) {
            self.critical("TextureInfo index not set");
        }
    
    }
    
}

function pdxGltfDataSampler() : pdxGltfDataAbstractBase() constructor {
    self.magFilter                       = undefined;    // integer                         Magnification filter.                                   No
    self.minFilter                       = undefined;    // integer                         Minification filter.                                    No
    self.wrapS                           = undefined;    // integer                         S (U) wrapping mode.                                    No, default: 10497
    self.wrapT                           = undefined;    // integer                         T (V) wrapping mode.                                    No, default: 10497
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("sampler name is not a string");
                }
            } else if(_name == "magFilter") { 
                if(!self.copy_integer("magFilter", _value)) {
                    self.add_error("sampler element magFilter is not an integer");
                }
            } else if(_name == "minFilter") { 
                if(!self.copy_integer("minFilter", _value)) {
                    self.add_error("sampler element minFilter is not an integer");
                }
            } else if(_name == "wrapS") { 
                if(!self.copy_integer("wrapS", _value)) {
                    self.add_error("sampler element wrapS is not an integer");
                }
            } else if(_name == "wrapT") { 
                if(!self.copy_integer("wrapT", _value)) {
                    self.add_error("sampler element wrapT is not an integer");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
            
            } );
        
        if(is_undefined(self.wrapS)) {
            self.wrapS = 10497;
        }
        if(is_undefined(self.wrapT)) {
            self.wrapT = 10497;
        }
        
    }     
}

function pdxGltfDataAccessor() : pdxGltfDataAbstractBase() constructor {
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

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("accessor name is not a string");
                }
            } else if(_name == "type") {
                if(!self.copy_string("type", _value)) {
                    self.add_error("accessor type is not a string");
                }
            } else if(_name == "normalized") {
                if(typeof(_value) == "bool") {
                    self.normalized = _value;
                } else {
                    self.add_error("accessor normalized is not a bool");
                }
            } else if(_name == "bufferView") { 
                if(!self.copy_integer("bufferView", _value)) {
                    self.add_error("accessor element bufferView is not an integer");
                }
            } else if(_name == "byteOffset") { 
                if(!self.copy_integer("byteOffset", _value)) {
                    self.add_error("accessor element byteOffset is not an integer");
                }
            } else if(_name == "componentType") { 
                if(!self.copy_integer("componentType", _value)) {
                    self.add_error("accessor element componentType is not an integer");
                }
            } else if(_name == "count") { 
                if(!self.copy_integer("count", _value)) {
                    self.add_error("accessor element count is not an integer");
                }
            } else if(_name == "min") { 
                if(!self.copy_array("min", _value, "number")) {
                    self.add_error("Bad Array for accessor element min");
                }
            } else if(_name == "max") { 
                if(!self.copy_array("max", _value, "number")) {
                    self.add_error("Bad Array for accessor element max");
                }
            } else if(_name == "sparse") { 
                self.sparse = new pdxGltfDataAccessorSparse();
                self.sparse.init(_value);
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
            
            } );
        
        if(is_undefined(self.normalized)) {
            self.normalized = false;
        }
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.componentType)) {
            self.critical("accessor componentType not set");
        }
        if(is_undefined(self.type)) {
            self.critical("accessor type not set");
        }
        if(is_undefined(self.count)) {
            self.critical("accessor count not set");
        }
        
    } 
}


function pdxGltfDataAnimation() : pdxGltfDataAbstractBase() constructor {
    self.channels                        = undefined;    // animation.channel [1-*]         An array of animation channels                          Yes
    self.samplers                        = undefined;    // animation.sampler [1-*]         An array of animation samplers                          Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
}

function pdxGltfDataBuffer() : pdxGltfDataAbstractBase() constructor {
    self.uri                             = undefined;    // string                          The URI (or IRI) of the buffer.                         No
    self.byteLength                      = undefined;    // integer                         The length of the buffer in bytes.                      Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
//    self.data                            = undefined;    // binary (internal)               Read on build stage                                     No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "byteLength") {
                if(!self.copy_integer("byteLength", _value)) {
                    self.add_error("buffer element byteLength is not an integer");
                }
            } else if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("buffer element name is not a string");
                }
            } else if(_name == "uri") {
                if(!self.copy_string("uri", _value)) {
                    self.add_error("buffer element uri is not a string");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });

        if(is_undefined(self.byteLength)) {
            self.critical("buffer byteLength not set");
        }
    }

}

function pdxGltfDataBufferView() : pdxGltfDataAbstractBase() constructor {
    self.buffer                          = undefined;    // integer                         The index of the buffer.                                Yes
    self.byteOffset                      = undefined;    // integer                         The offset into the buffer in bytes.                    No, default: 0
    self.byteLength                      = undefined;    // integer                         The length of the bufferView in bytes.                  Yes
    self.byteStride                      = undefined;    // integer                         The stride, in bytes.                                   No
    self.target                          = undefined;    // integer                         The hint representing the intended GPU buffer type      No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of mesh.primitive is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "buffer") {
                if(!self.copy_integer("buffer", _value)) {
                    self.add_error("bufferView element buffer is not an integer");
                }
            } else if(_name == "byteOffset") {
                if(!self.copy_integer("byteOffset", _value)) {
                    self.add_error("bufferView element byteOffset is not an integer");
                }
            } else if(_name == "byteLength") {
                if(!self.copy_integer("byteLength", _value)) {
                    self.add_error("bufferView element byteLength is not an integer");
                }
            } else if(_name == "byteStride") {
                if(!self.copy_integer("byteStride", _value)) {
                    self.add_error("bufferView element byteStride is not an integer");
                }
            } else if(_name == "target") {
                if(!self.copy_integer("target", _value)) {
                    self.add_error("bufferView element target is not an integer");
                }
            } else if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("bufferView element name is not a string");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
        
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.buffer)) {
            self.critical("buffer buffer not set");
        }
        if(is_undefined(self.byteLength)) {
            self.critical("buffer byteLength not set");
        }
    }
}

function pdxGltfDataCamera() : pdxGltfDataAbstractBase() constructor {
    self.orthographic                    = undefined;    // camera.orthographic             An orthographic camera                                  No
    self.perspective                     = undefined;    // camera.perspective              A perspective camera                                    No
    self.type                            = undefined;    // string                          camera uses a perspective or orthographic projection.   Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
}

function pdxGltfDataCameraOrthographic() : pdxGltfDataAbstractBase() constructor {
    self.xmag                            = undefined;    // number                          The horizontal magnification of the view. > 0           Yes
    self.ymag                            = undefined;    // number                          The vertical magnification of the view. > 0             Yes
    self.zfar                            = undefined;    // number                          The distance to the far clipping plane. > 0 > znear.    Yes
    self.znear                           = undefined;    // number                          The floating-point distance to the near clipping plane. Yes
}

function pdxGltfDataCameraPerspective() : pdxGltfDataAbstractBase() constructor {
    self.aspectRatio                     = undefined;    // number                          The aspect ratio of the field of view.                  No
    self.yfov                            = undefined;    // number                          The vertical field of view in radians. < π.             Yes
    self.zfar                            = undefined;    // number                          The floating-point distance to the far clipping plane.  No
    self.znear                           = undefined;    // number                          The floating-point distance to the near clipping plane. Yes
}

function pdxGltfDataImage() : pdxGltfDataAbstractBase() constructor {
    self.uri                             = undefined;    // string                          The URI (or IRI) of the image.                          No
    self.mimeType                        = undefined;    // string                          The image’s media type.                                 No
    self.bufferView                      = undefined;    // integer                         The index of the bufferView that contains the image     No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
//    self.data                            = undefined;    // binary (internal)               Read on build stage                                     No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of image is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "bufferView") {
                if(!self.copy_integer("bufferView", _value)) {
                    self.add_error("image element bufferView is not an integer");
                }
            } else if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("image element name is not a string");
                }
            } else if(_name == "uri") {
                if(!self.copy_string("uri", _value)) {
                    self.add_error("image element uri is not a string");
                }
            } else if(_name == "mimeType") {
                if(!self.copy_string("mimeType", _value)) {
                    self.add_error("image element mimeType is not a string");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
        });
    }
}


function pdxGltfDataTexture() : pdxGltfDataAbstractBase() constructor {
    self.sampler                         = undefined;    // integer                         The index of the sampler used by this texture           No
    self.source                          = undefined;    // integer                         The index of the image used by this texture             No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "name") {
                if(!self.copy_string("name", _value)) {
                    self.add_error("texture name is not a string");
                }
            } else if(_name == "sampler") { 
                if(!self.copy_integer("sampler", _value)) {
                    self.add_error("texture element sampler is not an integer");
                }
            } else if(_name == "source") { 
                if(!self.copy_integer("source", _value)) {
                    self.add_error("texture element source is not an integer");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
            
            } );
        
    }
}

function pdxGltfDataAccessorSparse() : pdxGltfDataAbstractBase() constructor {
    self.count                           = undefined;    // integer                         Number of deviating accessor vals in the sparse array   Yes
    self.indices                         = undefined;    // accessor.sparse.indices         An object pointing to a buffer view of indices          Yes
    self.values                          = undefined;    // accessor.sparse.values          An object pointing to a buffer view of values           Yes
    
    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "count") {
                if(!self.copy_integer("count", _value)) {
                    self.add_error("accessor.sparse element count is not an integer");
                }
            } else if(_name == "indices") { 
                if(typeof(_value) == "struct") {
                    self.indices = new pdxGltfDataAccessorSparseIndices();
                    self.indices.init(_value);
                } else {
                    self.add_error("accessor.sparse element indices is not a struct");
                }
            } else if(_name == "values") { 
                if(typeof(_value) == "struct") {
                    self.values = new pdxGltfDataAccessorSparseValues();
                    self.values.init(_value);
                } else {
                    self.add_error("accessor.values element indices is not a struct");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
            
            } );
        
        if(is_undefined(self.count)) {
            self.critical("sparse count not set");
        }
        if(is_undefined(self.indices)) {
            self.critical("sparse indicies not set");
        }
        if(is_undefined(self.values)) {
            self.critical("sparse values not set");
        }
    }        
    

}

function pdxGltfDataAccessorSparseIndices() : pdxGltfDataAbstractBase() constructor {
    self.bufferView                      = undefined;    // integer                         The index of the buffer view with sparse indices        Yes
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0
    self.componentType                   = undefined;    // integer                         The indices data type.                                  Yes

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "bufferView") {
                if(!self.copy_integer("bufferView", _value)) {
                    self.add_error("accessor.sparse.indicies element bufferView is not an integer");
                }
            } else if(_name == "byteOffset") {
                if(!self.copy_integer("bufferView", _value)) {
                    self.add_error("accessor.sparse.indicies element byteOffset is not an integer");
                }
            } else if(_name == "componentType") {
                if(!self.copy_integer("componentType", _value)) {
                    self.add_error("accessor.sparse.indicies element componentType is not an integer");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
            
            } );
        
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.bufferView)) {
            self.critical("sparse.indices bufferView not set");
        }
        if(is_undefined(self.componentType)) {
            self.critical("sparse.indices componentType not set");
        }
    }
}

function pdxGltfDataAccessorSparseValues() : pdxGltfDataAbstractBase() constructor {
    self.bufferView                      = undefined;    // integer                         The index of the buffer view with sparse indices        Yes
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0

    static init = function(object) {
        if(typeof(object) != "struct") {
            self.critical("Type of node is " + typeof(object));
        }
        struct_foreach(object, function(_name, _value) {
            if(_name == "bufferView") {
                if(!self.copy_integer("bufferView", _value)) {
                    self.add_error("accessor.sparse.values element bufferView is not an integer");
                }
            } else if(_name == "byteOffset") {
                if(!self.copy_integer("bufferView", _value)) {
                    self.add_error("accessor.sparse.values element byteOffset is not an integer");
                }
            } else if(_name == "extensions") {
                self.copy_extensions(_value);
            } else if(_name == "extras") {
                self.copy_extras(_value);
            }
            
            } );
        if(is_undefined(self.byteOffset)) {
            self.byteOffset = 0;
        }
        if(is_undefined(self.bufferView)) {
            self.critical("sparse.values bufferView not set");
        }
    }
}


function pdxGltfDataSkin() : pdxGltfDataAbstractBase() constructor {
    self.inverseBindMatrices             = undefined;    // integer                         accessor with 4x4 inverse-bind matrices.                No
    self.skeleton                        = undefined;    // integer                         The index of the node used as a skeleton root.          No
    self.joints                          = undefined;    // integer [1-*]                   Indices of skeleton nodes, used as joints in this skin. Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
}

function pdxGltfDataAnimationChannel() : pdxGltfDataAbstractBase() constructor {
    self.sampler                         = undefined;    // integer                         The index of a sampler in this animation                Yes
    self.target                          = undefined;    // animation.channel.target        The descriptor of the animated property.                Yes
}

function pdxGltfDataAnimationChannelTarget() : pdxGltfDataAbstractBase() constructor {
    self.node                            = undefined;    // integer                         The index of the node to animate                        No
    self.path                            = undefined;    // string                          The name of the node’s TRS property to animate...       Yes
}

function pdxGltfDataAnimationChannelSampler() : pdxGltfDataAbstractBase() constructor {
    self.input                           = undefined;    // integer                         The index of an accessor keyframe timestamps.           Yes
    self.interpolation                   = undefined;    // string                          Interpolation algorithm.                                No, default: "LINEAR"
    self.output                          = undefined;    // integer                         The index of an accessor, containing keyframe output    Yes
}






