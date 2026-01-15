draw_set_colour(c_white);
draw_text(20, 40, "LookAt : " + string(lookat_x) + " x "  + string(lookat_y));
draw_text(20, 60, "Virtual : " + string(virtual_width) + " x "  + string(virtual_height));
if(amodelok) {
    draw_text(20, 80, "BINs : " + string(amodel.bincount));
    draw_text(20, 100, "JSON : " + string(amodel.json));
    draw_text(20, 120, "TImg : " + string(sprites));
    draw_text(20, 140, "asset : " + string(amodel.asset));
    draw_text(20, 160, "uexts : " + string(amodel.extensionsUsed));
    draw_text(20, 180, "scene : " + string(amodel.scene));
    draw_text(20, 200, "scenes : " + string(amodel.scenes));
    draw_text(20, 220, "nodes : " + string(amodel.nodes));
    draw_text(20, 240, "mat : " + string(amodel.materials));
    draw_text(20, 260, "mesh : " + string(amodel.meshes));
    draw_text(20, 280, "tex : " + string(amodel.textures));
    draw_text(20, 300, "images : " + string(amodel.images));
    draw_text(20, 320, "accessors : " + string(amodel.accessors));
    draw_text(20, 340, "bufferViews : " + string(amodel.bufferViews));
    draw_text(20, 360, "samplers : " + string(amodel.samplers));

        draw_text(20, 400, "error : " + string(amodel.parse_error));

}