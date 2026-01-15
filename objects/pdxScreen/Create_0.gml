virtual_scale = 1;
virtual_width = 0;
virtual_height = 0;
lookat_x = 0;
lookat_y = 0;
cam = 0;
view = 0;
amodelok = false;
sprites = undefined;

amodel = new pdxGLB();
var _fn = "textured_1k_cube.glb";
/*
_fn = "basic_cube.glb";
_fn = "cube_pyramid.glb";
_fn = "world.glb";
 */
if(amodel.open(working_directory + _fn)) {
    amodel.read();
    amodelok = true;
}
