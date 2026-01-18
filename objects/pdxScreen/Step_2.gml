if(keyboard_check(vk_escape)) {
    game_end();
}

if(keyboard_check_pressed(vk_space)) {
    show_stats = !show_stats;
    tfps = 0;
    nfps = 0;
}
