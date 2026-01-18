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
amodel = new pdxGLB();
var _fn = "glb/textured_1k_cube.glb";
/*
_fn = "glb/basic_cube.glb";
_fn = "glb/cube_pyramid.glb";
_fn = "glb/squirrel.glb";
_fn = "glb/world.glb";
_fn = "glb/ShadedCubeOffsetX30.glb";
_fn = "glb/CubeRotateTranslate.glb";
_fn = "glb/castleated.glb";
_fn = "glb/Skeleton_Warrior.glb";
_fn = "glb/Skeleton_Warrior_Free.glb";
*/
_fn = "glb/ShadedCube.glb";
if(amodel.open(working_directory + _fn)) {
    amodel.read();
    amodelok = true;
}
