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
var _fn = "/glb/textured_1k_cube.glb";
/*
_fn = "/glb/basic_cube.glb";
_fn = "/glb/cube_pyramid.glb";
_fn = "/glb/world.glb";
 */
if(amodel.open(working_directory + _fn)) {
    amodel.read();
    amodelok = true;
}
