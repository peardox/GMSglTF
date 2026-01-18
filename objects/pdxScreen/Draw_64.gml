tfps += fps_real;
nfps++;

draw_set_colour(c_yellow);
draw_set_halign(fa_right);
draw_text((virtual_width * virtual_scale) - 20,  20, "FPS : " + string(fps) + " : RealFPS : " + string(tfps/nfps));
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_text(20, 40, "LookAt : " + string(lookat_x) + " x "  + string(lookat_y));
draw_text(20, 60, "Virtual : " + string(virtual_width) + " x "  + string(virtual_height));
if(amodelok && show_stats) {
    draw_text(20,  80, "asset : "       + string(amodel.asset)             );
    draw_text(20, 100, "rexts : "       + string(array_length(amodel.extensionsRequired)) + " : " + string(amodel.extensionsRequired));
    draw_text(20, 120, "uexts : "       + string(array_length(amodel.extensionsUsed)    ) + " : " + string(amodel.extensionsUsed)    );
    draw_text(20, 140, "scene : "       + string(amodel.scene)             );
    draw_text(20, 160, "scenes : "      + string(array_length(amodel.scenes)            ) + " : " + string(amodel.scenes)            );
    if(array_length(amodel.nodes) > 4) {
        draw_text(20, 180, "nodes : "       + string(array_length(amodel.nodes)             ) + " : [...]");
    } else {
        draw_text(20, 180, "nodes : "       + string(array_length(amodel.nodes)             ) + " : " + string(amodel.nodes)             );
    }
    draw_text(20, 200, "mat : "         + string(array_length(amodel.materials)         ) + " : " + string(amodel.materials)         );
    draw_text(20, 220, "mesh : "        + string(array_length(amodel.meshes)            ) + " : " + string(amodel.meshes)            );
    draw_text(20, 240, "tex : "         + string(array_length(amodel.textures)          ) + " : " + string(amodel.textures)          );
    draw_text(20, 260, "images : "      + string(array_length(amodel.images)            ) + " : " + string(amodel.images)            );
    if(array_length(amodel.accessors) > 4) {
        draw_text(20, 280, "accessors : "   + string(array_length(amodel.accessors)         ) + " : [...]");
    } else {
        draw_text(20, 280, "accessors : "   + string(array_length(amodel.accessors)         ) + " : " + string(amodel.accessors)         );
    }
    if(array_length(amodel.bufferViews) > 4) {
        draw_text(20, 300, "bufferViews : " + string(array_length(amodel.bufferViews)       ) + " : [...]");
    } else {
        draw_text(20, 300, "bufferViews : " + string(array_length(amodel.bufferViews)       ) + " : " + string(amodel.bufferViews)       );
    }
    draw_text(20, 320, "samplers : "    + string(array_length(amodel.samplers)          ) + " : " + string(amodel.samplers)          );
    draw_text(20, 340, "buffers : "     + string(array_length(amodel.buffers)           ) + " : " + string(amodel.buffers)           );
    if(array_length(amodel.animations) > 4) {
        draw_text(20, 360, "amins : "       + string(array_length(amodel.animations)        ) + " : [...]");
    } else {
        draw_text(20, 360, "amins : "       + string(array_length(amodel.animations)        ) + " : " + string(amodel.animations)        );
    }
    draw_text(20, 380, "skins : "       + string(array_length(amodel.skins)             ) + " : " + string(amodel.skins)             );

    draw_text(20, 420, "error : "       + string(amodel.error)             );
    draw_text(20, 440, "parse error : " + string(amodel.parse_error)       );

}