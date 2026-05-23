
function _init()
    tile_width = 8
    tile_height = 8
    grid_size = 16
    pos_x = 8
    pos_y = 8
    player = 1
    paddle_x = 64
    paddle_y = tile_height * (grid_size - 2)
end

function _update()
    get_button_held()
    move_paddle()
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
        player = 1 
    end
    if btn(0) then 
        new_x  = -1 
        player = 2 
    end
    if btn(2) then new_y = -1 end
    if btn(3) then new_y =  1 end
end

function move_paddle()
    local min_x = 0
    local max_x = tile_width * (grid_size - 1)
    paddle_x += new_x
    paddle_y += new_y
    paddle_x = mid(min_x, paddle_x, max_x)
end

function _draw()
    cls(0)
    map(0)
    spr(player, pos_x*8, pos_y*8)
    spr(8, paddle_x, paddle_y)
    pset(127,127,12)
    pset(0,127,12)
end
