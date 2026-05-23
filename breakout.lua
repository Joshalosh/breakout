
function _init()
    tile_size = 8
    grid_size = 16
    pos_x = 8
    pos_y = 8
    player = 1
    paddle_bot_x = tile_size*(grid_size*0.5)
    paddle_top_x = (tile_size*((grid_size*0.5)-1))
    paddle_left_x = 0
    paddle_right_x = tile_size * (grid_size - 1)
    paddle_bot_y = tile_size * (grid_size - 1)
    paddle_top_y = 0
    paddle_left_y = tile_size*(grid_size*0.5)
    paddle_right_y = (tile_size*((grid_size*0.5)-1))
end

function _update()
    get_button_held()
    move_paddles()
end


function get_button_held()
    -- Button layout --
    -- 0 = left
    -- 1 = right
    -- 2 = up 
    -- 3 = down
    -- 4 = C (O button)
    -- 5 = x (X button)
    new_x = 0
    new_y = 0
    if btn(1) then 
        new_x  = 1 
        new_y  = 1 
        player = 1 
    end
    if btn(0) then 
        new_x  = -1 
        new_y  = -1
        player = 2 
    end
    if btn(2) then new_y = -1 end
    if btn(3) then new_y =  1 end
end

function move_paddles()
    local min_pos = 0
    local max_pos = tile_size * (grid_size - 1)
    paddle_bot_x += new_x
    paddle_top_x -= new_x
    paddle_left_y += new_y
    paddle_right_y -= new_y
    paddle_bot_x = mid(min_pos, paddle_bot_x, max_pos)
    paddle_top_x = mid(min_pos, paddle_top_x, max_pos)
    paddle_left_y = mid(min_pos, paddle_left_y, max_pos)
    paddle_right_y = mid(min_pos, paddle_right_y, max_pos)
end

function _draw()
    cls(0)
    map(0)
    spr(player, pos_x*8, pos_y*8)
    spr(8, paddle_bot_x, paddle_bot_y)
    spr(9, paddle_top_x, paddle_top_y)
    spr(10, paddle_left_x, paddle_left_y)
    spr(11, paddle_right_x, paddle_right_y)
    pset(127,127,12)
    pset(0,127,12)
end
