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
    SCALAR,
    VEC2,
    VEC3,
    VEC4,
    MAT2,
    MAT3,
    MAT4
}

enum gltfComponentType {
    s8      = 5120,   //    signed byte     Signed, 2’s comp     8
    u8      = 5121,   //    unsigned byte   Unsigned             8
    s16     = 5122,   //    signed short    Signed, 2’s comp    16
    u16     = 5123,   //    unsigned short  Unsigned            16
    u32     = 5125,   //    unsigned int    Unsigned            32
    float   = 5126    //    float           Signed              32
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



// 28 out of 30 - ignoring extensions, extras


function pdxGltfDataAbstractBase() : pdxException() constructor {
    self.extensions                      = undefined;    // extension                       JSON object with extension-specific objects.            No
    self.extras                          = undefined;    // extras                          Application-specific data.                              No
    
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

function pdxGltfData() : pdxGltfDataAbstractBase() constructor {
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
}

function pdxGltfDataAsset() : pdxGltfDataAbstractBase() constructor {
    self.copyright                       = undefined;    // string                          copyright for display to credit the content creator     No
    self.generator                       = undefined;    // string                          Tool that generated this glTF model                     No
    self.version                         = undefined;    // string                          The glTF version in the form of <major>.<minor>         Yes
    self.minVersion                      = undefined;    // string                          The minimum glTF version in the form of <major>.<minor> No
}

function pdxGltfDataScene() : pdxGltfDataAbstractBase() constructor {
    self.nodes                           = undefined;    // integer [1-*]                   The indices of each root node.                          No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
}

function pdxGltfDataNode() : pdxGltfDataAbstractBase() constructor {
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
}
 
function pdxGltfDataMesh() : pdxGltfDataAbstractBase() constructor {
    self.primitives                      = undefined;    // mesh.primitive [1-*]            An array of primitives, each defining geometry.         Yes
    self.weights                         = undefined;    // number [1-*]                    Array of weights to be applied to the morph targets.    No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
}

function pdxGltfDataMeshPrimitive() : pdxGltfDataAbstractBase() constructor {
    self.attributes                      = undefined;    // object                          A plain JSON object,                                    Yes
    self.indices                         = undefined;    // integer                         The index of the accessor containing vertex indices.    No
    self.material                        = undefined;    // integer                         The index of the material to apply.                     No
    self.mode                            = undefined;    // integer                         The topology type of primitives to render.              No, default: 4
    self.targets                         = undefined;    // object [1-*]                    An array of morph targets.                              No
    
    static validate = function() {
        var _req = [ ["attributes", gltfVariableType.object] ];
        var _def = [ ["mode", 4] ];
        self.do_validate(_req, _def);
    }
    
}

function pdxGltfDataMeshAttributes() : pdxGltfDataAbstractBase() constructor {
    self.position                        = undefined;
    self.normal                          = undefined;
    self.tangent                         = undefined;
    self.texcoord                        = undefined;
    self.color                           = undefined;
    self.joints                          = undefined;
    self.weights                         = undefined;
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
}

function pdxGltfDataMaterialPbrMetallicRoughness() : pdxGltfDataAbstractBase() constructor {
    self.baseColorFactor                 = undefined;    // number [4]                      The factors for the base color of the material.         No, default: [1,1,1,1]
    self.baseColorTexture                = undefined;    // textureInfo                     The base color texture.                                 No
    self.metallicFactor                  = undefined;    // number                          The factor for the metalness of the material.           No, default: 1
    self.roughnessFactor                 = undefined;    // number                          The factor for the roughness of the material.           No, default: 1
    self.metallicRoughnessTexture        = undefined;    // textureInfo                     The metallic-roughness texture.                         No
}

function pdxGltfDataMaterialNormalTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD attribute           No, default: 0
    self.scale                           = undefined;    // number                          The scalar parameter applied to each normalTex vector   No, default: 1
}

function pdxGltfDataMaterialOcclusionTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
    self.strength                        = undefined;    // number                          A scalar multiplier for the amount of occlusion.        No, default: 1
}

function pdxGltfDataTextureInfo() : pdxGltfDataAbstractBase() constructor {
    self.index                           = undefined;    // integer                         The index of the texture.                               Yes
    self.texCoord                        = undefined;    // integer                         The set index of texture’s TEXCOORD                     No, default: 0
}

function pdxGltfDataSampler() : pdxGltfDataAbstractBase() constructor {
    self.magFilter                       = undefined;    // integer                         Magnification filter.                                   No
    self.minFilter                       = undefined;    // integer                         Minification filter.                                    No
    self.wrapS                           = undefined;    // integer                         S (U) wrapping mode.                                    No, default: 10497
    self.wrapT                           = undefined;    // integer                         T (V) wrapping mode.                                    No, default: 10497
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
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
}

function pdxGltfDataBufferView() : pdxGltfDataAbstractBase() constructor {
    self.buffer                          = undefined;    // integer                         The index of the buffer.                                Yes
    self.byteOffset                      = undefined;    // integer                         The offset into the buffer in bytes.                    No, default: 0
    self.byteLength                      = undefined;    // integer                         The length of the bufferView in bytes.                  Yes
    self.byteStride                      = undefined;    // integer                         The stride, in bytes.                                   No
    self.target                          = undefined;    // integer                         The hint representing the intended GPU buffer type      No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
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
}

function pdxGltfDataSkin() : pdxGltfDataAbstractBase() constructor {
    self.inverseBindMatrices             = undefined;    // integer                         accessor with 4x4 inverse-bind matrices.                No
    self.skeleton                        = undefined;    // integer                         The index of the node used as a skeleton root.          No
    self.joints                          = undefined;    // integer [1-*]                   Indices of skeleton nodes, used as joints in this skin. Yes
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
}

function pdxGltfDataTexture() : pdxGltfDataAbstractBase() constructor {
    self.sampler                         = undefined;    // integer                         The index of the sampler used by this texture           No
    self.source                          = undefined;    // integer                         The index of the image used by this texture             No
    self.name                            = undefined;    // string                          The user-defined name of this object.                   No
}

function pdxGltfDataAccessorSparse() : pdxGltfDataAbstractBase() constructor {
    self.count                           = undefined;    // integer                         Number of deviating accessor vals in the sparse array   Yes
    self.indices                         = undefined;    // accessor.sparse.indices         An object pointing to a buffer view of indices          Yes
    self.values                          = undefined;    // accessor.sparse.values          An object pointing to a buffer view of values           Yes
}

function pdxGltfDataAccessorSparseIndices() : pdxGltfDataAbstractBase() constructor {
    self.bufferView                      = undefined;    // integer                         The index of the buffer view with sparse indices        Yes
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0
    self.componentType                   = undefined;    // integer                         The indices data type.                                  Yes
}

function pdxGltfDataAccessorSparseValues() : pdxGltfDataAbstractBase() constructor {
    self.bufferView                      = undefined;    // integer                         The index of the buffer view with sparse indices        Yes
    self.byteOffset                      = undefined;    // integer                         The offset relative to the start of the buffer view     No, default: 0
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






