virtual_scale = 1;
virtual_width = 0;
virtual_height = 0;
lookat_x = 0;
lookat_y = 0;
cam = 0;
view = 0;
amodelok = false;
sprites = undefined;
tfps = 0;
nfps = 0;
show_stats = true;
// amodel = new pdxGLB();
//amodel = new pdxGLTF();
var _fn = "glb/textured_1k_cube.glb";
/*
_fn = "glb/basic_cube.glb";
_fn = "glb/cube_pyramid.glb";
_fn = "glb/squirrel.glb";
_fn = "glb/world.glb";
_fn = "glb/ShadedCubeOffsetX30.glb";
_fn = "glb/CubeRotateTranslate.glb";
_fn = "glb/watchtower.glb";
_fn = "glb/Skeleton_Warrior.glb";
_fn = "glb/Skeleton_Warrior_Free.glb";
_fn = "glb/ShadedCube.glb";
_fn = "gltf/basic_cube.gltf";
_fn = "glb\\door-rotate-square-a.glb";
_fn = "glb/assetforge-door.glb";
_fn = "gltf/Rotator.gltf";
_fn = "glb/rotate.glb";
*/
_fn = "glb/basic_cube.glb";
_fn = "gltf/basic_cube.gltf";
amodel = open_model(working_directory + _fn);
if(amodel) {
// if(amodel.open(working_directory + _fn)) {
    amodel.read();
    amodelok = true;
}
