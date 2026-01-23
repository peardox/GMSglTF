enum glbVariableType {
    integer,
    float,
    vec3,
    vec4,
    object,
    array
}


function pdxGltfAbstractBase() : pdxException() constructor {
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

function pdxGltfScene() : pdxException() constructor {
    self.nodes                           = undefined;    // integer [1-*]                   The indices of each root node.                          No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}

function pdxGltfNode() : pdxException() constructor {
    self.camera                          = undefined;    // integer                         The index of the camera referenced by this node.        No
    self.children                        = undefined;    // integer [1-*]                   The indices of this node’s children.                    No
    self.skin                            = undefined;    // integer                         The index of the skin referenced by this node.          No
    self.matrix                          = undefined;    // number [16]                     A floating-point 4x4 transformation matrix              No, default: [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1]
    self.mesh                            = undefined;    // integer                         The index of the mesh in this node.                     No
    self.rotation                        = undefined;    // number [4]                      The node’s unit quaternion rotation (x, y, z, w)        No, default: [0,0,0,1]
    self.scale                           = undefined;    // number [3]                      The node’s non-uniform scale along x, y, and z          No, default: [1,1,1]
    self.translation                     = undefined;    // number [3]                      The node’s translation along the x, y, and z axes.      No, default: [0,0,0]
    self.weights                         = undefined;    // number [1-*]                    The weights of the instantiated morph target.           No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}
 
function pdxGltfMesh() : pdxException() constructor {
    self.primitives                      = undefined;    // mesh.primitive [1-*]            An array of primitives, each defining geometry.         Yes
    self.weights                         = undefined;    // number [1-*]                    Array of weights to be applied to the morph targets.    No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}

function pdxGltfMeshPrimitive() : pdxGltfAbstractBase() constructor {
    self.attributes                      = undefined;    // object                          A plain JSON object,                                    Yes
    self.indices                         = undefined;    // integer                         The index of the accessor containing vertex indices.    No
    self.material                        = undefined;    // integer                         The index of the material to apply.                     No
    self.mode                            = undefined;    // integer                         The topology type of primitives to render.              No, default: 4
    self.targets                         = undefined;    // object [1-*]                    An array of morph targets.                              No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
    
    static validate = function() {
        self.do_validate([["attributes", glbVariableType.object]], [["mode", 4]]);
    }
    
}

function pdxGltfMeshAttributes() : pdxException() constructor {
    self.position                        = undefined;
    self.normal                          = undefined;
    self.tangent                         = undefined;
    self.texcoord                        = undefined;
    self.color                           = undefined;
    self.joints                          = undefined;
    self.weights                         = undefined;
}

function pdxGltfMaterial() : pdxException() constructor {
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
    self.pbrMetallicRoughness            = undefined;    // material.pbrMetallicRoughness   PBR metallic-roughness material model                   No
    self.normalTexture                   = undefined;    // material.normalTextureInfo      The tangent space normal texture.                       No
    self.occlusionTexture                = undefined;    // material.occlusionTextureInfo   The occlusion texture.                                  No
    self.emissiveTexture                 = undefined;    // textureInfo                     The emissive texture.                                   No
    self.emissiveFactor                  = undefined;    // number [3]                      The factors for the emissive color of the material.     No, default: [0,0,0]
    self.alphaMode                       = undefined;    // string                          The alpha rendering mode of the material.               No, default: "OPAQUE"
    self.alphaCutoff                     = undefined;    // number                          The alpha cutoff value of the material.                 No, default: 0.5
    self.doubleSided                     = undefined;    // boolean                         Specifies whether the material is double sided.         No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}

function pdxGltfMaterialPbrMetallicRoughness() : pdxException() constructor {
    self.baseColorFactor                 = undefined;    // number [4]                      The factors for the base color of the material.         No, default: [1,1,1,1]
    self.baseColorTexture                = undefined;    // textureInfo                     The base color texture.                                 No
    self.metallicFactor                  = undefined;    // number                          The factor for the metalness of the material.           No, default: 1
    self.roughnessFactor                 = undefined;    // number                          The factor for the roughness of the material.           No, default: 1
    self.metallicRoughnessTexture        = undefined;    // textureInfo                     The metallic-roughness texture.                         No
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}

function pdxGltfMaterialNormalTextureInfo() : pdxException() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD attribute           No, default: 0
    self.scale                           = undefined;    // number                          The scalar parameter applied to each normalTex vector   No, default: 1
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}

function pdxGltfMaterialOcclusionTextureInfo() : pdxException() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
    self.strength                        = undefined;    // number                          A scalar multiplier for the amount of occlusion.        No, default: 1
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}

function pdxGltfTextureInfo() : pdxException() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
}

