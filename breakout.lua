
level_data = {
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {0, 2, 0, 2, 0, 2, 0},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1}
}

active_blocks = {}

function load_level(data)
    local start_x      = 36
    local start_y      = 48
    local block_width  = 8
    local block_height = 4

    for row = 1, #data do 
        for col = 1, #data[row] do 
            local block_type = data[row][col]

            if block_type > 0 then 
                local new_block = {
                    x = start_x + (col - 1) * block_width,
                    y = start_y + (row - 1) * block_height, 
                    type = block_type, 
                    alive = true
                }

                add(active_blocks, new_block)
            end
        end
    end
end

function _init()
    tile_size      = 8
    grid_size      = 16
    pos_x          = 8
    pos_y          = 8
    paddle_bot_x   = tile_size*(grid_size*0.5)
    paddle_bot_y   = tile_size * (grid_size - 1)
    paddle_top_x   = (tile_size*((grid_size*0.5)-1))
    paddle_top_y   = 0
    paddle_left_x  = 0
    paddle_left_y  = tile_size*(grid_size*0.5)
    paddle_right_x = tile_size * (grid_size - 1)
    paddle_right_y = (tile_size*((grid_size*0.5)-1))
    load_level(level_data)
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
    end
    if btn(0) then 
        new_x  = -1 
        new_y  = -1
    end
    if btn(2) then new_y = -1 end
    if btn(3) then new_y =  1 end
end

function move_paddles()
    local min_pos  = 0
    local max_pos  = tile_size * (grid_size - 1)
    local velocity = 2

    paddle_bot_x   += (new_x * velocity)
    paddle_top_x   -= (new_x * velocity)
    paddle_left_y  += (new_y * velocity)
    paddle_right_y -= (new_y * velocity)
    paddle_bot_x    = mid(min_pos, paddle_bot_x, max_pos)
    paddle_top_x    = mid(min_pos, paddle_top_x, max_pos)
    paddle_left_y   = mid(min_pos, paddle_left_y, max_pos)
    paddle_right_y  = mid(min_pos, paddle_right_y, max_pos)
end

function _draw()
    cls(0)
    --map(0)
    spr(8, paddle_bot_x, paddle_bot_y)
    spr(9, paddle_top_x, paddle_top_y)
    spr(10, paddle_left_x, paddle_left_y)
    spr(11, paddle_right_x, paddle_right_y)
    --[[
    spr(13, pos_x*8, pos_y*8)
    spr(13, pos_x*8+8, pos_y*8)
    spr(13, pos_x*8, ((pos_y*8)-4))
    spr(13, (pos_x*8)+8, ((pos_y*8)-4))
    ]]
    for block in all(active_blocks) do
        if block.alive then
            local sprite_id = 0 
            if block.type == 1 then sprite_id = 13 end
            if block.type == 2 then sprite_id = 15 end

            spr(sprite_id, block.x, block.y)
        end
    end
    pset(127,127,12)
    pset(0,127,12)
end
